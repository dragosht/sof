divert(-1)

include(`debug.m4')

dnl Define macros for DAI IN/OUT widgets and DAI config

dnl DAI name)
define(`N_DAI', DAI_NAME)
define(`N_DAI_OUT', DAI_NAME`.OUT')
define(`N_DAI_IN', DAI_NAME`.IN')

dnl W_DAI_OUT(type, index, dai_link, format, periods_sink, periods_source)
define(`W_DAI_OUT',
`SectionVendorTuples."'N_DAI_OUT($2)`_tuples_w_comp" {'
`	tokens "sof_comp_tokens"'
`	tuples."word" {'
`		SOF_TKN_COMP_PERIOD_SINK_COUNT'		STR($5)
`		SOF_TKN_COMP_PERIOD_SOURCE_COUNT'	STR($6)
`	}'
`}'
`SectionData."'N_DAI_OUT($2)`_data_w_comp" {'
`	tuples "'N_DAI_OUT($2)`_tuples_w_comp"'
`}'
`SectionVendorTuples."'N_DAI_OUT($2)`_tuples_w" {'
`	tokens "sof_dai_tokens"'
`	tuples."word" {'
`		SOF_TKN_DAI_INDEX'	$2
`		SOF_TKN_DAI_DIRECTION'	"0"
`	}'
`}'
`SectionData."'N_DAI_OUT($2)`_data_w" {'
`	tuples "'N_DAI_OUT($2)`_tuples_w"'
`}'
`SectionVendorTuples."'N_DAI_OUT($2)`_tuples_str" {'
`	tokens "sof_dai_tokens"'
`	tuples."string" {'
`		SOF_TKN_DAI_TYPE'	$1
`	}'
`}'
`SectionData."'N_DAI_OUT($2)`_data_str" {'
`	tuples "'N_DAI_OUT($2)`_tuples_str"'
`}'
`SectionVendorTuples."'N_DAI_OUT($2)`_tuples_comp_str" {'
`	tokens "sof_comp_tokens"'
`	tuples."string" {'
`		SOF_TKN_COMP_FORMAT'	STR($4)
`	}'
`}'
`SectionData."'N_DAI_OUT($2)`_data_comp_str" {'
`	tuples "'N_DAI_OUT($2)`_tuples_comp_str"'
`}'
`SectionWidget."'N_DAI_OUT`" {'
`	index "'PIPELINE_ID`"'
`	type "dai_in"'
`	stream_name' STR($3)
`	no_pm "true"'
`	data ['
`		"'N_DAI_OUT($2)`_data_w"'
`		"'N_DAI_OUT($2)`_data_w_comp"'
`		"'N_DAI_OUT($2)`_data_str"'
`		"'N_DAI_OUT($2)`_data_comp_str"'
`	]'
`}')

dnl W_DAI_IN(type, index, dai_link, format, periods_sink, periods_source)
define(`W_DAI_IN',
`SectionVendorTuples."'N_DAI_IN($2)`_tuples_w_comp" {'
`	tokens "sof_comp_tokens"'
`	tuples."word" {'
`		SOF_TKN_COMP_PERIOD_SINK_COUNT'		STR($5)
`		SOF_TKN_COMP_PERIOD_SOURCE_COUNT'	STR($6)
`	}'
`}'
`SectionData."'N_DAI_IN($2)`_data_w_comp" {'
`	tuples "'N_DAI_IN($2)`_tuples_w_comp"'
`}'
`SectionVendorTuples."'N_DAI_IN($2)`_tuples_w" {'
`	tokens "sof_dai_tokens"'
`	tuples."word" {'
`		SOF_TKN_DAI_INDEX'	$2
`		SOF_TKN_DAI_DIRECTION'	"1"
`	}'
`}'
`SectionData."'N_DAI_IN($2)`_data_w" {'
`	tuples "'N_DAI_IN($2)`_tuples_w"'
`}'
`SectionVendorTuples."'N_DAI_IN($2)`_tuples_str" {'
`	tokens "sof_dai_tokens"'
`	tuples."string" {'
`		SOF_TKN_DAI_TYPE'	$1
`	}'
`}'
`SectionData."'N_DAI_IN($2)`_data_str" {'
`	tuples "'N_DAI_IN($2)`_tuples_str"'
`}'
`SectionVendorTuples."'N_DAI_IN($2)`_tuples_comp_str" {'
`	tokens "sof_comp_tokens"'
`	tuples."string" {'
`		SOF_TKN_COMP_FORMAT'	STR($4)
`	}'
`}'
`SectionData."'N_DAI_IN($2)`_data_comp_str" {'
`	tuples "'N_DAI_IN($2)`_tuples_comp_str"'
`}'
`SectionWidget."'N_DAI_IN`" {'
`	index "'PIPELINE_ID`"'
`	type "dai_out"'
`	stream_name' STR($3)
`	no_pm "true"'
`	data ['
`		"'N_DAI_IN($2)`_data_w"'
`		"'N_DAI_IN($2)`_data_w_comp"'
`		"'N_DAI_IN($2)`_data_str"'
`		"'N_DAI_IN($2)`_data_comp_str"'
`	]'
`}')

dnl D_DAI(id, playback, capture, data))
define(`D_DAI', `SectionDAI."'N_DAI`" {'
`	index "'PIPELINE_ID`"'
`	id "'$1`"'
`	playback "'$2`"'
`	capture "'$3`"'
`}')

dnl DAI Config)
define(`N_DAI_CONFIG', `DAICONFIG.'$1)

define(`DAI_HWCONFIG_SECTION',
`SectionHWConfig."'$1$2`-eval($5+j-6)" {'
`'
`	id		"eval($5+j-6)"'
`'
`ifelse($1, `SSP', `argn(j,$@)', `}')'
`ifelse($1, `DMIC', `argn(j,$@)', `')'
`ifelse(eval(i<=6), `1', `',`define(`i', decr(i))define(`j', incr(j))$0($@)')')

define(`DAI_HWCONFIG_SECTIONS',
`pushdef(`i', $#)pushdef(`j', `6')DAI_HWCONFIG_SECTION($@)popdef(i)popdef(j)')


define(`DAI_HWCONFIG_LIST_LOOP',
`		"'$1$2`-eval($5+j-6)"'
`ifelse(eval(i<=6),`1', `',`define(`i', decr(i))define(`j', incr(j))$0($@)')')

define(`DAI_HWCONFIG_LIST',`pushdef(`i', $#)pushdef(`j', `6')DAI_HWCONFIG_LIST_LOOP($@)popdef(i)popdef(j)')

dnl DAI_CONFIG(type, idx, link_id, name, hw_conf_id, ssp_config/dmic_config)
define(`DAI_CONFIG',
`'
`DAI_HWCONFIG_SECTIONS($@)'
`'
`SectionVendorTuples."'N_DAI_CONFIG($1$2)`_tuples_common" {'
`	tokens "sof_dai_tokens"'
`	tuples."string" {'
`		SOF_TKN_DAI_TYPE'		STR($1)
`	}'
`	tuples."word" {'
`		SOF_TKN_DAI_INDEX'		STR($2)
`	}'
`}'
`SectionData."'N_DAI_CONFIG($1$2)`_data_common" {'
`	tuples "'N_DAI_CONFIG($1$2)`_tuples_common"'
`}'
`'
`SectionBE."'$4`" {'
`	id "'$3`"'
`	index "0"'
`	default_hw_conf_id	"'$5`"'
`'
`	hw_configs ['
`DAI_HWCONFIG_LIST($@)'
`	]'
`	data ['
`		ifelse($1, `HDA', `', "'N_DAI_CONFIG($1$2)`_data")'
`		"'N_DAI_CONFIG($1$2)`_data_common"'
`ifelse($1, `DMIC',`		"'N_DAI_CONFIG($1$2)`_pdm_data"', `')'
`	]'
`}'
`DEBUG_DAI_CONFIG($1, $3)'
)

dnl DAI_ADD(pipeline,
dnl     pipe id, dai type, dai_index, dai_be,
dnl     buffer, periods, format,
dnl     frames, deadline, priority, core)
define(`DAI_ADD',
`undefine(`PIPELINE_ID')'
`undefine(`DAI_TYPE')'
`undefine(`DAI_INDEX')'
`undefine(`DAI_BE')'
`undefine(`DAI_BUF')'
`undefine(`DAI_PERIODS')'
`undefine(`DAI_FORMAT')'
`undefine(`SCHEDULE_FRAMES')'
`undefine(`SCHEDULE_DEADLINE')'
`undefine(`SCHEDULE_PRIORITY')'
`undefine(`SCHEDULE_CORE')'
`define(`PIPELINE_ID', $2)'
`define(`DAI_TYPE', STR($3))'
`define(`DAI_INDEX', STR($4))'
`define(`DAI_BE', $5)'
`define(`DAI_BUF', $6)'
`define(`DAI_NAME', $3$4)'
`define(`DAI_PERIODS', $7)'
`define(`DAI_FORMAT', $8)'
`define(`SCHEDULE_FRAMES', $9)'
`define(`SCHEDULE_DEADLINE', $10)'
`define(`SCHEDULE_PRIORITY', $11)'
`define(`SCHEDULE_CORE', $12)'
`include($1)'
`DEBUG_DAI($3, $4)'
)

divert(0)dnl
