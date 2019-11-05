// SPDX-License-Identifier: BSD-3-Clause
//
// Copyright(c) 2016 Intel Corporation. All rights reserved.
//

#include <sof/audio/component.h>

/*
 * Hello World tutorial: amp example
 */

#define trace_amp(__e, ...) trace_event(TRACE_CLASS_AMP, __e, ##__VA_ARGS__)
#define tracev_amp(__e, ...) tracev_event(TRACE_CLASS_AMP, __e, ##__VA_ARGS__)
#define trace_amp_error(__e, ...) \
	trace_error(TRACE_CLASS_AMP, __e, ##__VA_ARGS__)

struct amp_comp_data {
	int placeholder;
};

static struct comp_dev *amp_new(struct sof_ipc_comp *comp)
{
	struct comp_dev *dev;
	struct sof_ipc_comp_process *amp;
	struct sof_ipc_comp_process *ipc_amp =
		(struct sof_ipc_comp_process *)comp;
	struct amp_comp_data *cd;

	dev = rzalloc(RZONE_RUNTIME, SOF_MEM_CAPS_RAM,
		      COMP_SIZE(struct sof_ipc_comp_process));
	if (!dev)
		return NULL;

	cd = rzalloc(RZONE_RUNTIME, SOF_MEM_CAPS_RAM, sizeof(*cd));
	if (!cd) {
		rfree(dev);
		return NULL;
	}

	amp = (struct sof_ipc_comp_process *)&dev->comp;
	assert(!memcpy_s(amp, sizeof(*amp), ipc_amp,
			 sizeof(struct sof_ipc_comp_process)));

	comp_set_drvdata(dev, cd);

	dev->state = COMP_STATE_READY;

	trace_amp("amp_new()");

	return dev;
}

static void amp_free(struct comp_dev *dev)
{
	struct comp_data *cd = comp_get_drvdata(dev);

	rfree(cd);
	rfree(dev);
}

static int amp_trigger(struct comp_dev *dev, int cmd)
{
	trace_amp("amp_trigger() cmd %d", cmd);
	return comp_set_state(dev, cmd);
}

static int amp_prepare(struct comp_dev *dev)
{
	int ret;
	struct comp_buffer *sink_buf;
	struct comp_buffer *src_buf;
	struct sof_ipc_comp_config *config = COMP_GET_CONFIG(dev);
	enum sof_ipc_frame src_fmt;
	uint32_t src_per_bytes;
	uint32_t sink_per_bytes;
	enum sof_ipc_frame sink_fmt;

	ret = comp_set_state(dev, COMP_TRIGGER_PREPARE);
	if (ret < 0)
		return ret;

	if (ret == COMP_STATUS_STATE_ALREADY_SET)
		return PPL_STATUS_PATH_STOP;

	src_buf = list_first_item(&dev->bsource_list,
				  struct comp_buffer, sink_list);
	sink_buf = list_first_item(&dev->bsink_list,
				   struct comp_buffer, source_list);

	src_fmt = comp_frame_fmt(src_buf->source);
	src_per_bytes = comp_period_bytes(sink_buf->source, dev->frames);

	sink_fmt = comp_frame_fmt(sink_buf->sink);
	sink_per_bytes = comp_period_bytes(sink_buf->sink, dev->frames);

	if (dev->params.direction == SOF_IPC_STREAM_PLAYBACK)
		dev->params.frame_fmt = src_fmt;
	else
		dev->params.frame_fmt = sink_fmt;

	ret = buffer_set_size(sink_buf,
			      sink_per_bytes * config->periods_sink);
	if (ret < 0) {
		trace_amp_error("amp_prepare() error: "
                                "buffer_set_size() failed %d", ret);
		goto err;
	}

	trace_amp("amp_prepare() src_fmt %d bytes: %u sink_fmt %d bytes: %u",
		  src_fmt, src_per_bytes, sink_fmt, sink_per_bytes);

	return 0;
err:
	return ret;
}

static int amp_reset(struct comp_dev *dev)
{
	return comp_set_state(dev, COMP_TRIGGER_RESET);
}

static int amp_copy(struct comp_dev *dev)
{
	struct comp_copy_limits cl;
	int ret;
	int frame;
	int channel;
	uint32_t buff_frag = 0;
	int16_t *src;
	int16_t *dst;

	ret = comp_get_copy_limits(dev, &cl);
	if (ret < 0) {
		return ret;
	}

	for (frame = 0; frame < cl.frames; frame++) {
		for (channel = 0; channel < dev->params.channels; channel++) {
			src = buffer_read_frag_s16(cl.source, buff_frag);
			dst = buffer_write_frag_s16(cl.sink, buff_frag);
			*dst = *src;
			++buff_frag;
		}
	}

	comp_update_buffer_produce(cl.sink, cl.sink_bytes);
	comp_update_buffer_consume(cl.source, cl.source_bytes);

	return 0;
}

struct comp_driver comp_amp = {
	.type = SOF_COMP_AMP,
	.ops = {
		.new = amp_new,
		.free = amp_free,
		.params = NULL,
		.cmd = NULL,
		.trigger = amp_trigger,
		.prepare = amp_prepare,
		.reset = amp_reset,
		.copy = amp_copy,
		.cache = NULL
	},
};

static void sys_comp_amp_init(void)
{
	comp_register(&comp_amp);
}

DECLARE_MODULE(sys_comp_amp_init);
