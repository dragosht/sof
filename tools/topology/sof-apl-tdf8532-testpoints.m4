#
# Topology for generic Apollolake board with TDF8532
#

# Include topology builder
include(`utils.m4')
include(`dai.m4')
include(`pipeline.m4')
include(`ssp.m4')

# Include TLV library
include(`common/tlv.m4')

# Include Token library
include(`sof/tokens.m4')

# Include Apollolake DSP configuration
include(`platform/intel/bxt.m4')

#
# Define the pipelines
#

# PCM0 ----> volume -----> SSP5(TestPin out)	(Pipeline 1)
#      <---- volume <----- SSP5(TestPin in)	(Pipeline 2)
#
# "Virtual" SSP Ports hacked in the firmware!
#
# PCM1 ----> volume -----> SSP6(TestPin out)	(Pipeline 3)
#      <---- volume <----- SSP6(TestPin in)	(Pipeline 4)
#
# PCM2 ----> volume -----> SSP7(TestPin out)	(Pipeline 5)
#      <---- volume <----- SSP7(TestPin in)	(Pipeline 6)
#

#dnl PCM_CAPABILITIES(name, formats,
#	rate_min, rate_max,
#	channels_min, channels_max,
#	periods_min, periods_max,
#	period_size_min, period_size_max,
#	buffer_size_min, buffer_size_max)

#dnl PIPELINE_PCM_DAI_ADD(pipeline,
#dnl     pipe id, pcm, max channels, format,
#dnl     frames, deadline, priority, core,
#dnl     dai type, dai_index, dai format, periods)


# Test points!

# Low Latency playback pipeline 1 on PCM 0 using max 2 channels of s16le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-playback.m4,
	1, 0, 2, s16le,
	48, 1000, 0, 0, SSP, 5, s16le, 2)

# Low Latency capture pipeline 2 on PCM 0 using max 2 channels of s16le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-capture.m4,
	2, 0, 2, s16le,
	48, 1000, 0, 0, SSP, 5, s16le, 2)

# Low Latency playback pipeline 3 on PCM 1 using max 2 channels of s16le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-playback.m4,
	3, 1, 2, s32le,
	48, 1000, 0, 0, SSP, 6, s32le, 2)

# Low Latency capture pipeline 4 on PCM 1 using max 2 channels of s16le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-capture.m4,
	4, 1, 2, s32le,
	48, 1000, 0, 0, SSP, 6, s32le, 2)

# Low Latency playback pipeline 5 on PCM 2 using max 2 channels of s16le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-playback.m4,
	5, 2, 2, s16le,
	48, 1000, 0, 0, SSP, 7, s16le, 2)

# Low Latency capture pipeline 5 on PCM 2 using max 2 channels of s16le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-capture.m4,
	6, 2, 2, s16le,
	48, 1000, 0, 0, SSP, 7, s16le, 2)


#
# DAIs configuration
#
# dnl DAI_ADD(pipeline,
# dnl     pipe id, dai type, dai_index, dai_be,
# dnl     buffer, periods, format,
# dnl     frames, deadline, priority, core)

# Test points!

# playback DAI is SSP5 using 2 periods
# Buffers use s16le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
	1, SSP, 5, SSP5-Codec1,
	PIPELINE_SOURCE_1, 2, s16le,
	48, 1000, 0, 0)

# capture DAI is SSP5 using 2 periods
# Buffers use s16le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-capture.m4,
	2, SSP, 5, SSP5-Codec1,
	PIPELINE_SINK_2, 2, s16le,
	48, 1000, 0, 0)


# playback DAI is SSP6 using 2 periods
# Buffers use s16le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
	3, SSP, 6, SSP5-Codec2,
	PIPELINE_SOURCE_3, 2, s32le,
	48, 1000, 0, 0)

# capture DAI is SSP6 using 2 periods
# Buffers use s16le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-capture.m4,
	4, SSP, 6, SSP5-Codec2,
	PIPELINE_SINK_4, 2, s32le,
	48, 1000, 0, 0)

# playback DAI is SSP7 using 2 periods
# Buffers use s16le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
	5, SSP, 7, SSP5-Codec3,
	PIPELINE_SOURCE_5, 2, s16le,
	48, 1000, 0, 0)

# capture DAI is SSP7 using 2 periods
# Buffers use s16le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-capture.m4,
	6, SSP, 7, SSP5-Codec3,
	PIPELINE_SINK_6, 2, s16le,
	48, 1000, 0, 0)


# PCM Low Latency, id 0

# dnl PCM_DUPLEX_ADD(name, pcm_id, playback, capture)

PCM_DUPLEX_ADD(Port5, 5, PIPELINE_PCM_1, PIPELINE_PCM_2)
PCM_DUPLEX_ADD(Port6, 6, PIPELINE_PCM_3, PIPELINE_PCM_4)
PCM_DUPLEX_ADD(Port7, 7, PIPELINE_PCM_5, PIPELINE_PCM_6)

#
# BE configurations - overrides config in ACPI if present
#

# dnl DAI_CONFIG(type, idx, link_id, name, ssp_config/dmic_config)
# dnl SSP_CONFIG(format, mclk, bclk, fsync, tdm, ssp_config_data)
# dnl SSP_CLOCK(clock, freq, codec_master)
# dnl SSP_TDM(slots, width, tx_mask, rx_mask)
# dnl SSP_CONFIG_DATA(type, idx, valid bits, mclk_id) [mclk_id is optional]

# SSP DAI CONFIG id 0 should match the member (id) in struct snd_soc_dai_link
# in kernel machine driver (usually under linux/sound/soc/intel/boards/)

# SSP DAI CONFIG id 1 should match the member (id) in struct snd_soc_dai_link
# in kernel machine driver (usually under linux/sound/soc/intel/boards/)

# Test points!

DAI_CONFIG(SSP, 5, 5, SSP5-Codec1,
	   SSP_CONFIG(I2S, SSP_CLOCK(mclk, 24576000, codec_mclk_in),
		      SSP_CLOCK(bclk, 1536000, codec_slave),
		      SSP_CLOCK(fsync, 48000, codec_slave),
		      SSP_TDM(2, 16, 3, 3),
		      SSP_CONFIG_DATA(SSP, 5, 16)))

DAI_CONFIG(SSP, 6, 6, SSP5-Codec2,
	   SSP_CONFIG(I2S, SSP_CLOCK(mclk, 24576000, codec_mclk_in),
		      SSP_CLOCK(bclk, 3072000, codec_slave),
		      SSP_CLOCK(fsync, 48000, codec_slave),
		      SSP_TDM(2, 32, 3, 3),
		      SSP_CONFIG_DATA(SSP, 6, 32)))

DAI_CONFIG(SSP, 7, 7, SSP5-Codec3,
	   SSP_CONFIG(I2S, SSP_CLOCK(mclk, 24576000, codec_mclk_in),
		      SSP_CLOCK(bclk, 1536000, codec_slave),
		      SSP_CLOCK(fsync, 48000, codec_slave),
		      SSP_TDM(2, 16, 3, 3),
		      SSP_CONFIG_DATA(SSP, 7, 16)))



# dnl VIRTUAL_DAPM_ROUTE_IN(name, dai type, dai index, direction, index)
# dnl VIRTUAL_DAPM_ROUTE_OUT(name, dai type, dai index, direction, index)

VIRTUAL_DAPM_ROUTE_IN(TestPin_ssp5_in, SSP, 5, IN, 0)
VIRTUAL_DAPM_ROUTE_OUT(TestPin_ssp5_out, SSP, 5, OUT, 1)

VIRTUAL_DAPM_ROUTE_IN(TestPin_ssp6_in, SSP, 6, IN, 2)
VIRTUAL_DAPM_ROUTE_OUT(TestPin_ssp6_out, SSP, 6, OUT, 3)

VIRTUAL_DAPM_ROUTE_IN(TestPin_ssp7_in, SSP, 7, IN, 4)
VIRTUAL_DAPM_ROUTE_OUT(TestPin_ssp7_out, SSP, 7, OUT, 5)


# dnl VIRTUAL_WIDGET(name, index)

VIRTUAL_WIDGET(ssp5 Tx, out_drv, 6)
VIRTUAL_WIDGET(ssp5 Rx, out_drv, 7)
VIRTUAL_WIDGET(ssp6 Tx, out_drv, 8)
VIRTUAL_WIDGET(ssp6 Rx, out_drv, 9)
VIRTUAL_WIDGET(ssp7 Tx, out_drv, 10)
VIRTUAL_WIDGET(ssp7 Rx, out_drv, 11)

