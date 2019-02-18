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
# PCM0 -----> Volume -----> SSP4
# PCM1 <----> Volume <----> SSP2(Dirana Pb/Cp)
# PCM2 <----> Volume <----> SSP0(BT HFP out/in)
# PCM3 <----- Volume <----- SSP1(HDMI in)
# PCM4 <----> Volume <----> SSP3(Modem out/in)
# PCM5 <----> Volume <----> SSP5(TestPin out/in)
#

# Low Latency playback pipeline 1 on PCM 0 using max 2 channels of s32le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-playback.m4,
	1, 0, 2, s32le,
	48, 1000, 0, 0, SSP, 4, s32le, 2)

# Low Latency playback pipeline 2 on PCM 1 using max 8 channels of s32le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-playback.m4,
	2, 1, 2, s32le,
	48, 1000, 0, 0, SSP, 2, s32le, 2)

# Low Latency capture pipeline 3 on PCM 1 using max 8 channels of s32le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-capture.m4,
	3, 1, 2, s32le,
	48, 1000, 0, 0, SSP, 2, s32le, 2)

# Low Latency playback pipeline 4 on PCM 2 using max 2 channels of s16le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-playback.m4,
	4, 2, 2, s16le,
	48, 1000, 0, 0, SSP, 0, s16le, 2)

# Low Latency capture pipeline 5 on PCM 2 using max 2 channels of s16le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-capture.m4,
	5, 2, 2, s16le,
	48, 1000, 0, 0, SSP, 0, s16le, 2)

# Low Latency capture pipeline 6 on PCM 3 using max 2 channels of s16le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-capture.m4,
	6, 3, 2, s16le,
	48, 1000, 0, 0, SSP, 1, s16le, 2)

# Low Latency playback pipeline 7 on PCM 4 using max 2 channels of s16le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-playback.m4,
	7, 4, 2, s16le,
	48, 1000, 0, 0, SSP, 3, s16le, 2)

# Low Latency capture pipeline 8 on PCM 4 using max 2 channels of s16le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-capture.m4,
	8, 4, 2, s16le,
	48, 1000, 0, 0, SSP, 3, s16le, 2)

# Low Latency playback pipeline 9 on PCM 5 using max 2 channels of s16le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-playback.m4,
	9, 5, 2, s16le,
	48, 1000, 0, 0, SSP, 5, s16le, 2)

# Low Latency capture pipeline 10 on PCM 5 using max 2 channels of s16le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-capture.m4,
	10, 5, 2, s16le,
	48, 1000, 0, 0, SSP, 5, s16le, 2)


#
# DAIs configuration
#

# playback DAI is SSP0 using 2 periods
# Buffers use s16le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
	4, SSP, 0, SSP0-Codec,
	PIPELINE_SOURCE_4, 2, s16le,
	48, 1000, 0, 0)

# capture DAI is SSP0 using 2 periods
# Buffers use s16le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-capture.m4,
	5, SSP, 0, SSP0-Codec,
	PIPELINE_SINK_5, 2, s16le,
	48, 1000, 0, 0)

# capture DAI is SSP1 using 2 periods
# Buffers use s16le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-capture.m4,
	6, SSP, 1, SSP1-Codec,
	PIPELINE_SINK_6, 2, s16le,
	48, 1000, 0, 0)

# playback DAI is SSP2 using 2 periods
# Buffers use s32le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
	2, SSP, 2, SSP2-Codec,
	PIPELINE_SOURCE_2, 2, s32le,
	48, 1000, 0, 0)

# capture DAI is SSP2 using 2 periods
# Buffers use s32le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-capture.m4,
	3, SSP, 2, SSP2-Codec,
	PIPELINE_SINK_3, 2, s32le,
	48, 1000, 0, 0)

# playback DAI is SSP3 using 2 periods
# Buffers use s16le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
	7, SSP, 3, SSP3-Codec,
	PIPELINE_SOURCE_7, 2, s16le,
	48, 1000, 0, 0)

# capture DAI is SSP3 using 2 periods
# Buffers use s16le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-capture.m4,
	8, SSP, 3, SSP3-Codec,
	PIPELINE_SINK_8, 2, s16le,
	48, 1000, 0, 0)

# playback DAI is SSP4 using 2 periods
# Buffers use s32le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
	1, SSP, 4, SSP4-Codec,
	PIPELINE_SOURCE_1, 2, s32le,
	48, 1000, 0, 0)

# playback DAI is SSP5 using 2 periods
# Buffers use s16le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
	9, SSP, 5, SSP5-Codec,
	PIPELINE_SOURCE_9, 2, s16le,
	48, 1000, 0, 0)

# capture DAI is SSP5 using 2 periods
# Buffers use s16le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-capture.m4,
	10, SSP, 5, SSP5-Codec,
	PIPELINE_SINK_10, 2, s16le,
	48, 1000, 0, 0)

# PCM Low Latency, id 0
PCM_DUPLEX_ADD(Port0, 2, PIPELINE_PCM_4, PIPELINE_PCM_5)
PCM_CAPTURE_ADD(Port1, 3, PIPELINE_PCM_6)
PCM_DUPLEX_ADD(Port2, 1, PIPELINE_PCM_2, PIPELINE_PCM_3)
PCM_DUPLEX_ADD(Port3, 4, PIPELINE_PCM_7, PIPELINE_PCM_8)
PCM_PLAYBACK_ADD(Port4, 0, PIPELINE_PCM_1)
PCM_DUPLEX_ADD(Port5, 5, PIPELINE_PCM_9, PIPELINE_PCM_10)

#
# BE configurations - overrides config in ACPI if present
#
DAI_CONFIG(SSP, 0, 0, SSP0-Codec,
	   SSP_CONFIG(I2S, SSP_CLOCK(mclk, 24576000, codec_mclk_in),
		      SSP_CLOCK(bclk, 1536000, codec_slave),
		      SSP_CLOCK(fsync, 48000, codec_slave),
		      SSP_TDM(2, 16, 3, 3),
		      SSP_CONFIG_DATA(SSP, 0, 16)))

DAI_CONFIG(SSP, 1, 1, SSP1-Codec,
	   SSP_CONFIG(I2S, SSP_CLOCK(mclk, 24576000, codec_mclk_in),
		      SSP_CLOCK(bclk, 1536000, codec_slave),
		      SSP_CLOCK(fsync, 48000, codec_slave),
		      SSP_TDM(2, 16, 3, 3),
		      SSP_CONFIG_DATA(SSP, 1, 16)))

DAI_CONFIG(SSP, 2, 2, SSP2-Codec,
	   SSP_CONFIG(DSP_B, SSP_CLOCK(mclk, 24576000, codec_mclk_in),
		      SSP_CLOCK(bclk, 12288000, codec_slave),
		      SSP_CLOCK(fsync, 48000, codec_slave),
		      SSP_TDM(8, 32, 3, 48),
		      SSP_CONFIG_DATA(SSP, 2, 32)))

DAI_CONFIG(SSP, 3, 3, SSP3-Codec,
	   SSP_CONFIG(I2S, SSP_CLOCK(mclk, 24576000, codec_mclk_in),
		      SSP_CLOCK(bclk, 1536000, codec_slave),
		      SSP_CLOCK(fsync, 48000, codec_slave),
		      SSP_TDM(2, 16, 3, 3),
		      SSP_CONFIG_DATA(SSP, 3, 16)))

DAI_CONFIG(SSP, 4, 4, SSP4-Codec,
	   SSP_CONFIG(DSP_B, SSP_CLOCK(mclk, 24576000, codec_mclk_in),
		      SSP_CLOCK(bclk, 12288000, codec_slave),
		      SSP_CLOCK(fsync, 48000, codec_slave),
		      SSP_TDM(2, 32, 15, 15),
		      SSP_CONFIG_DATA(SSP, 4, 32)))

DAI_CONFIG(SSP, 5, 5, SSP5-Codec,
	   SSP_CONFIG(I2S, SSP_CLOCK(mclk, 24576000, codec_mclk_in),
		      SSP_CLOCK(bclk, 1536000, codec_slave),
		      SSP_CLOCK(fsync, 48000, codec_slave),
		      SSP_TDM(2, 16, 3, 3),
		      SSP_CONFIG_DATA(SSP, 5, 16)))


VIRTUAL_DAPM_ROUTE_IN(BtHfp_ssp0_in, SSP, 0, IN, 0)
VIRTUAL_DAPM_ROUTE_OUT(BtHfp_ssp0_out, SSP, 0, OUT, 1)
VIRTUAL_DAPM_ROUTE_IN(hdmi_ssp1_in, SSP, 1, IN, 2)
VIRTUAL_DAPM_ROUTE_IN(dirana_in, SSP, 2, IN, 3)
VIRTUAL_DAPM_ROUTE_IN(dirana_aux_in, SSP, 2, IN, 4)
VIRTUAL_DAPM_ROUTE_IN(dirana_tuner_in, SSP, 2, IN, 5)
VIRTUAL_DAPM_ROUTE_OUT(dirana_out, SSP, 2, OUT, 6)
VIRTUAL_DAPM_ROUTE_IN(Modem_ssp3_in, SSP, 3, IN, 7)
VIRTUAL_DAPM_ROUTE_OUT(Modem_ssp3_out, SSP, 3, OUT, 8)
VIRTUAL_DAPM_ROUTE_OUT(codec0_out, SSP, 4, OUT, 9)
VIRTUAL_DAPM_ROUTE_IN(TestPin_ssp5_in, SSP, 5, IN, 10)
VIRTUAL_DAPM_ROUTE_OUT(TestPin_ssp5_out, SSP, 5, OUT, 11)
VIRTUAL_WIDGET(ssp0 Tx, out_drv, 12)
VIRTUAL_WIDGET(ssp0 Rx, out_drv, 13)
VIRTUAL_WIDGET(ssp1 Rx, out_drv, 14)
VIRTUAL_WIDGET(ssp2 Tx, out_drv, 15)
VIRTUAL_WIDGET(ssp2 Rx, out_drv, 16)
VIRTUAL_WIDGET(ssp3 Tx, out_drv, 17)
VIRTUAL_WIDGET(ssp3 Rx, out_drv, 18)
VIRTUAL_WIDGET(ssp4 Tx, out_drv, 19)
VIRTUAL_WIDGET(ssp5 Tx, out_drv, 20)
VIRTUAL_WIDGET(ssp5 Rx, out_drv, 21)
