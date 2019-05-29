/*
 * Copyright (c) 2018, Intel Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *   * Neither the name of the Intel Corporation nor the
 *     names of its contributors may be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * Author: Marcin Maka <marcin.maka@linux.intel.com>
 */

#include <sof/dai.h>

#define trace_dai(__e, ...) trace_event(TRACE_CLASS_DAI, __e, ##__VA_ARGS__)

struct dai_info {
	struct dai_type_info *dai_type_array;
	size_t num_dai_types;
};

static struct dai_info lib_dai = {
	.dai_type_array = NULL,
	.num_dai_types = 0
};

void dai_install(struct dai_type_info *dai_type_array, size_t num_dai_types)
{
	lib_dai.dai_type_array = dai_type_array;
	lib_dai.num_dai_types = num_dai_types;
}

static inline struct dai_type_info *dai_find_type(uint32_t type)
{
	struct dai_type_info *dti;

	for (dti = lib_dai.dai_type_array;
	     dti < lib_dai.dai_type_array + lib_dai.num_dai_types; dti++) {
		if (dti->type == type)
			return dti;
	}
	return NULL;
}

struct dai *dai_get(uint32_t type, uint32_t index, uint32_t flags)
{
	int ret = 0;
	struct dai_type_info *dti;
	struct dai *d;

	dti = dai_find_type(type);
	if (!dti)
		return NULL; /* type not found */

	for (d = dti->dai_array; d < dti->dai_array + dti->num_dais; d++) {
		if (d->index != index)
			continue;
		/* device created? */
		spin_lock(&d->lock);
		if (d->sref == 0) {
			ret = -ENODEV;
			if (flags & DAI_CREAT) {
				ret = dai_probe(d);
				d->num_configs = 0;
				d->cur_config = 0;
			}
		}
		if (!ret)
			d->sref++;

		trace_dai("dai_get(), d = %p, sref = %d",
			  (uintptr_t)d, d->sref);

		spin_unlock(&d->lock);

		return !ret ? d : NULL;
	}
	trace_error(TRACE_CLASS_DAI, "dai_get() error: "
		    "type = %d, index = %d not found", type, index);
	return NULL;
}

void dai_put(struct dai *dai)
{
	int i, ret;

	spin_lock(&dai->lock);
	if (--dai->sref == 0) {
		ret = dai_remove(dai);
		if (ret < 0) {
			trace_error(TRACE_CLASS_DAI,
				    "dai_put() error: "
				    "dai_remove() failed ret = %d", ret);
		}
		for (i = 0; i < dai->num_configs; i++)
			rfree(dai->configs[i]);
		dai->num_configs = 0;
		dai->cur_config = 0;
	}
	trace_event(TRACE_CLASS_DAI, "dai_put(), dai = %p, sref = %d",
		    (uintptr_t)dai, dai->sref);
	spin_unlock(&dai->lock);
}

int dai_add_config(struct dai *dai, struct sof_ipc_dai_config *config)
{
	int crt;
	int ret = 0;

	spin_lock(&dai->lock);
	if (dai->num_configs == DAI_CONFIG_MAX) {
		trace_error(TRACE_CLASS_DAI,
			    "dai_add_config() error: "
			    "max configs allowed: %d\n",
			    dai->num_configs);
		ret = -EINVAL;
		goto out;
	}

	crt = dai->num_configs;
	dai->configs[crt] = rzalloc(RZONE_RUNTIME, SOF_MEM_CAPS_RAM,
				    config->hdr.size);
	if (!dai->configs[crt]) {
		ret = -ENOMEM;
		goto out;
	}
	assert(!memcpy_s(dai->configs[crt], config->hdr.size,
			 config, config->hdr.size));

	dai->num_configs++;

	trace_dai("dai_add_config(), dai %d,%d num configs %d\n",
		  dai->drv->type, dai->index,
		  dai->num_configs);

out:
	spin_unlock(&dai->lock);

	return ret;
}

int dai_set_config(struct dai *dai, int i)
{
	int ret;

	spin_lock(&dai->lock);

	if (i < 0 || i >= dai->num_configs) {
		trace_error(TRACE_CLASS_DAI,
			    "dai_set_config() error: "
			    "invalid config index: %d\n", i);
		ret = -EINVAL;
		goto error;
	}
	trace_dai("dai_set_config(), dai %d,%d current config -> %d\n",
		  dai->drv->type, dai->index, i);

	dai->cur_config = i;

	spin_unlock(&dai->lock);

	return dai->drv->ops.set_config(dai, dai->configs[i]);

error:
	spin_unlock(&dai->lock);
	return ret;
}
