 
****************************************
Report : resources
Design : PN
Version: N-2017.09-SP2
Date   : Mon Mar  6 10:12:45 2023
****************************************


Resource Report for this hierarchy in file /home/rain/FPGA/jacky/PN_grouped.v
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| add_x_6        | DW01_inc       | width=4    | add_282 (PN_grouped.v:282) |
| sub_x_14       | DW01_dec       | width=4    | sub_390 (PN_grouped.v:390) |
| add_x_15       | DW01_inc       | width=4    | add_391 (PN_grouped.v:391) |
| add_x_21       | DW01_inc       | width=4    | add_412 (PN_grouped.v:412) |
| mult_x_22      | DW02_mult      | A_width=16 | mult_492 (PN_grouped.v:492) |
                |                | B_width=16 |                            |
| add_x_26       | DW01_inc       | width=4    | add_537 (PN_grouped.v:537) |
| add_x_37       | DW01_inc       | width=4    | stack/add_927 (PN_grouped.v:927) |
| sub_x_38       | DW01_dec       | width=4    | stack/sub_929 (PN_grouped.v:929) |
| gt_x_47        | DW_cmp         | width=16   | bitonics_sorter/sort_lv3_4/gt_945 (PN_grouped.v:945) |
| gt_x_48        | DW_cmp         | width=16   | bitonics_sorter/sort_lv3_3/gt_945 (PN_grouped.v:945) |
| gt_x_49        | DW_cmp         | width=16   | bitonics_sorter/sort_lv3_2/gt_945 (PN_grouped.v:945) |
| gt_x_52        | DW_cmp         | width=16   | bitonics_sorter/sort_lv3_1/gt_945 (PN_grouped.v:945) |
| gt_x_56        | DW_cmp         | width=16   | bitonics_sorter/sort_lv2_4/gt_945 (PN_grouped.v:945) |
| gt_x_59        | DW_cmp         | width=16   | bitonics_sorter/sort_lv2_3/gt_945 (PN_grouped.v:945) |
| gt_x_61        | DW_cmp         | width=16   | bitonics_sorter/sort_lv2_2/gt_945 (PN_grouped.v:945) |
| gt_x_63        | DW_cmp         | width=16   | bitonics_sorter/sort_lv2_1/gt_945 (PN_grouped.v:945) |
| gt_x_65        | DW_cmp         | width=16   | bitonics_sorter/sort_lv1_4/gt_945 (PN_grouped.v:945) |
| gt_x_67        | DW_cmp         | width=16   | bitonics_sorter/sort_lv1_3/gt_945 (PN_grouped.v:945) |
| gt_x_69        | DW_cmp         | width=16   | bitonics_sorter/sort_lv1_2/gt_945 (PN_grouped.v:945) |
| gt_x_71        | DW_cmp         | width=16   | bitonics_sorter/sort_lv1_1/gt_945 (PN_grouped.v:945) |
| gt_x_73        | DW_cmp         | width=16   | bitonics_sorter/lv3_4/gt_945 (PN_grouped.v:945) |
| gt_x_75        | DW_cmp         | width=16   | bitonics_sorter/lv3_3/gt_945 (PN_grouped.v:945) |
| gt_x_81        | DW_cmp         | width=16   | bitonics_sorter/lv2_4/gt_945 (PN_grouped.v:945) |
| gt_x_83        | DW_cmp         | width=16   | bitonics_sorter/lv2_3/gt_945 (PN_grouped.v:945) |
| gt_x_89        | DW_cmp         | width=16   | bitonics_sorter/lv1_4/gt_945 (PN_grouped.v:945) |
| gt_x_91        | DW_cmp         | width=16   | bitonics_sorter/lv1_3/gt_945 (PN_grouped.v:945) |
| sub_x_27       | DW01_dec       | width=4    | sub_543 (PN_grouped.v:543) |
|                |                |            | sub_545 (PN_grouped.v:545) |
| DP_OP_219J1_122_8965            |            |                            |
|                | DP_OP_219J1_122_8965 |      |                            |
| DP_OP_225J1_123_1235            |            |                            |
|                | DP_OP_225J1_123_1235 |      |                            |
=============================================================================

Datapath Report for DP_OP_219J1_122_8965
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_219J1_122_8965 | sub_158 (PN_grouped.v:158)                          |
|                      | sub_384 (PN_grouped.v:384)                          |
|                      | eq_158 (PN_grouped.v:158)                           |
==============================================================================

==============================================================================
|       |      | Data     |       |                                          |
| Var   | Type | Class    | Width | Expression                               |
==============================================================================
| I1    | PI   | Unsigned | 4     |                                          |
| I2    | PI   | Unsigned | 4     |                                          |
| T99   | IFO  | Signed   | 32    | O1                                       |
| O1    | PO   | Signed   | 5     | I1 - $unsigned(1'b1) ( PN_grouped.v:158 PN_grouped.v:384 ) |
| O2    | PO   | Unsigned | 1     | I2 == $unsigned(T99) (PN_grouped.v:158)  |
==============================================================================

Datapath Report for DP_OP_225J1_123_1235
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_225J1_123_1235 | add_482 (PN_grouped.v:482)                          |
|                      | add_495 (PN_grouped.v:495)                          |
|                      | add_498 (PN_grouped.v:498)                          |
|                      | add_496 (PN_grouped.v:496)                          |
|                      | sub_496 (PN_grouped.v:496) C5961 (PN_grouped.v:495) |
|                      | C5960 (PN_grouped.v:485) C5962 (PN_grouped.v:480)   |
|                      | sub_486 (PN_grouped.v:486)                          |
|                      | sub_488 (PN_grouped.v:488)                          |
==============================================================================

==============================================================================
|       |      | Data     |       |                                          |
| Var   | Type | Class    | Width | Expression                               |
==============================================================================
| I1    | PI   | Signed   | 16    |                                          |
| I2    | PI   | Signed   | 16    |                                          |
| I3    | PI   | Unsigned | 1     |                                          |
| I4    | PI   | Signed   | 16    |                                          |
| I5    | PI   | Unsigned | 1     |                                          |
| I6    | PI   | Signed   | 16    |                                          |
| T223  | IFO  | Signed   | 16    | { I3, I5 } ? O1 : I4 ( PN_grouped.v:480 PN_grouped.v:485 PN_grouped.v:495 ) |
| O1    | PO   | Unsigned | 16    | I1 + I2 ( PN_grouped.v:482 PN_grouped.v:495 PN_grouped.v:496 PN_grouped.v:498 ) |
| O2    | PO   | Signed   | 16    | I6 - T223 ( PN_grouped.v:486 PN_grouped.v:488 PN_grouped.v:496 ) |
==============================================================================


Datapath Extraction Report

Information: Operator associated with resources 'lt_495 (PN_grouped.v:495)' in design 'PN' breaks the datapath extraction because there is leakage due to truncation on the fanout of its driver 'add_482 (PN_grouped.v:482) add_495 (PN_grouped.v:495) add_498 (PN_grouped.v:498) add_496 (PN_grouped.v:496) sub_496 (PN_grouped.v:496)'.  (HDL-120)


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| add_x_6            | DW01_inc         | apparch (area)     |                |
| sub_x_14           | DW01_dec         | apparch (area)     |                |
| add_x_15           | DW01_inc         | apparch (area)     |                |
| add_x_21           | DW01_inc         | apparch (area)     |                |
| mult_x_22          | DW02_mult        | apparch (area)     |                |
|                    |                  | mult_arch: benc_radix4              |
| add_x_26           | DW01_inc         | apparch (area)     |                |
| add_x_37           | DW01_inc         | apparch (area)     |                |
| sub_x_38           | DW01_dec         | apparch (area)     |                |
| gt_x_49            | DW_cmp           | apparch (area)     |                |
| gt_x_52            | DW_cmp           | apparch (area)     |                |
| gt_x_59            | DW_cmp           | apparch (area)     |                |
| gt_x_63            | DW_cmp           | apparch (area)     |                |
| gt_x_65            | DW_cmp           | apparch (area)     |                |
| gt_x_67            | DW_cmp           | apparch (area)     |                |
| gt_x_69            | DW_cmp           | apparch (area)     |                |
| gt_x_71            | DW_cmp           | apparch (area)     |                |
| gt_x_73            | DW_cmp           | apparch (area)     |                |
| gt_x_75            | DW_cmp           | apparch (area)     |                |
| gt_x_81            | DW_cmp           | apparch (area)     |                |
| gt_x_83            | DW_cmp           | apparch (area)     |                |
| gt_x_89            | DW_cmp           | apparch (area)     |                |
| gt_x_91            | DW_cmp           | apparch (area)     |                |
| sub_x_27           | DW01_dec         | apparch (area)     |                |
| DP_OP_219J1_122_8965                  |                    |                |
|                    | DP_OP_219J1_122_8965 | str (area)     |                |
| DP_OP_225J1_123_1235                  |                    |                |
|                    | DP_OP_225J1_123_1235 | str (area)     |                |
===============================================================================

1
