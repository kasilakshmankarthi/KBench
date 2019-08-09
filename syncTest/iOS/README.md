# Indirect branch mispredict latency test (test_app)

Branch target determined by a random value in an array; the array contains 256K random values, each value is in the interval [0-99]. With 1 branch target, it is assumed there are no mispredicts. With 100 branch targets (random), it is assumed the test mispredicts every time.

# Test 1: Fixed number of targets (100)
WARNING: This test was removed in favor of test #2

## Test code
```
// x0 - length of array
// x1 - pointer to array
// x2 - length of test
_indirectBranchTest:
    mov  x8, #0         // loop counter
    sub  x8, x8, #1     // subtract 1 because of pre-increment in loop
    sub  x5, x0, #1     // mask for array index
    adr  x6, #LfirstTarget  // base address of first indirect branch target

Lloop:
    add  x8, x8, #1     // pre-increment since this is the common branch point (i.e. avoid inserting common loop termination after indirect branch)
    cmp  x8, x2
    b.eq Ldone

    and  x4, x8, x5     // calculate array index
    ldrb w4, [x1, x4]   // load random value from array
    lsl  x4, x4, #2     // calculate indirect branch target using random value
    add  x4, x6, x4     //  and base address of first indirect branch target
//    add x4, x6, #0      // for baseline measurement, replace above add with this instruction (use same address for all indirect branches)

    br   x4

LfirstTarget:
.rept 100
    b Lloop
.endr

Ldone:
    ret
```

--------

## Results

### Tweedle-Dumb (A10 - iOS 11.0.1)
| # Branch Targets | Total Samples   | Running Time | Instructions (FIXED_INSTRUCTIONS)   | Cycles (FIXED_CYCLES)   | IPC | Branches (INST_BRANCH)  | MispredictedBranches (SYNC_BR_ANY_MISP) | L1DataCacheLoadMisses (SYNC_DC_LOAD_MISS)   | FED_IC_MISS_DEM | Symbol Name |
| --- | ------- | ----------- | --------------- | --------------- | ------- | --------------- | ------------- | ---------- | ----------- | -------------------------------------- |
| 1   | 880     | 880.0ms     | 8,735,571,039   | 2,079,264,532   | 4.201   | 2,903,880,395   | 676,955       | 1,052,826  | 1,695,044   | -[UIViewController loadViewIfRequired] |
| 100 | 11507   | 11507.0ms   | 9,443,219,226   | 23,039,357,673  | 0.41    | 3,054,539,084   | 966,545,421   | 10,859,108 | 19,191,826  | -[UIViewController loadViewIfRequired] |


### Coxa (A11 - iOS 12.1)
| # Branch Targets | Total Samples   | Running Time | Instructions (FIXED_INSTRUCTIONS)   | Cycles (FIXED_CYCLES)   | IPC | Branches (INST_BRANCH)  | MispredictedBranches (SYNC_BR_ANY_MISP) | L1DataCacheLoadMisses (SYNC_DC_LOAD_MISS)   | FED_IC_MISS_DEM | Symbol Name |
| --- | ------- | ----------- | --------------- | --------------- | ------- | --------------- | ------------- | ---------- | ----------- | -------------------------------------- |
| 1   | 845     | 845.0ms     | 9,025,843,748   | 2,022,119,788   | 4.464   | 3,007,150,420   | 4,172         | 499,285    | 15,046      | -[UIViewController loadViewIfRequired] |
| 100 | 11115   | 11115.0ms   | 9,148,131,197   | 23,078,198,359  | 0.396   | 3,032,250,715   | 990,276,658   | 1,677,738  | 21,555      | -[UIViewController loadViewIfRequired] |


### Flourine (A12 - iOS 12.1)
| # Branch Targets | Total Samples   | Running Time | Instructions (FIXED_INSTRUCTIONS)   | Cycles (FIXED_CYCLES)   | IPC | Branches (INST_BRANCH)  | MispredictedBranches (SYNC_BR_ANY_MISP) | L1DataCacheLoadMisses (SYNC_DC_LOAD_MISS)   | FED_IC_MISS_DEM | Symbol Name |
| --- | ------- | ----------- | --------------- | --------------- | ------- | --------------- | ------------- | ---------- | ----------- | -------------------------------------- |
| 1   | 806     | 806.0ms     | 9,003,080,639   | 2,029,325,769   | 4.436   | 2,999,546,506   | 3,484         | 264,533    | 7,238       | -[UIViewController loadViewIfRequired] |
| 100 | 8844    | 8844.0ms    | 9,119,822,070   | 22,222,361,105  | 0.41    | 3,025,572,763   | 990,774,343   | 747,098    | 12,149      | -[UIViewController loadViewIfRequired] |

--------

## Summary

Using 1 branch target as the baseline
| Name          | Chip  | Cycles            | Cycles per 'br'   |
| ------------- | ----- | ----------------- | ----------------- |
| Tweedle-Dumb  | A10   | 20,960,093,141    | 21                |
| Coxa          | A11   | 21,056,078,571    | 21                |
| Flourine      | A12   | 20,193,035,336    | 20                |

--------



# Test 2: Varying number of targets (1-256)

## Test code
```
// x0 - length of array
// x1 - pointer to array
// x2 - length of test
// x3 - number of branch targets
_indirectBranchTest:
    mov  x8, #0         // loop counter
    sub  x8, x8, #1     // subtract 1 because of pre-increment in loop
    sub  x5, x0, #1     // mask for array index
    sub  x3, x3, #1     // mask used for number of branch targets
    adr  x6, #LfirstTarget  // base address of first indirect branch target

Lloop:
    add  x8, x8, #1     // pre-increment since this is the common branch point (i.e. avoid inserting common loop termination after indirect branch)
    cmp  x8, x2
    b.eq Ldone

    and  x4, x8, x5     // calculate array index
    ldrb w4, [x1, x4]   // load random value from array
    and  x4, x4, x3     // mask for specifying number of branch targets
    lsl  x4, x4, #2     // calculate indirect branch target using random value
    add  x4, x6, x4     //  and base address of first indirect branch target
    br   x4

LfirstTarget:
.rept 256
    b Lloop
.endr

Ldone:
    ret
```

--------

## Results

### Tweedle-Dumb (A10 - iOS 11.0.1)
| # Branch Targets | Total Samples | Running Time | Instructions    | Cycles          | IPC     | Branches        | MispredictedBranches | L1DataCacheLoadMisses | FED_IC_MISS_DEM | Symbol Name |
| ---------------- | ------------- | ------------ | --------------- | --------------- | ------- | --------------- | -------------------- | --------------------- | --------------- | ----------- |
| 1                | 897           | 897.0ms      | 9,810,116,531   | 2,147,087,434   | 4.569   | 2,937,678,302   | 560,928              | 846,901               | 1,260,470       | -[ViewController measure_test:] |
| 2                | 7044          | 7044.0ms     | 10,081,171,322  | 13,979,564,942  | 0.721   | 2,999,984,281   | 493,133,279          | 4,031,502             | 5,674,090       | -[ViewController measure_test:] |
| 4                | 9784          | 9784.0ms     | 10,185,048,642  | 19,492,837,057  | 0.523   | 3,021,205,446   | 740,134,697          | 7,450,741             | 8,174,243       | -[ViewController measure_test:] |
| 8                | 11041         | 11041.0ms    | 10,217,504,992  | 21,916,211,256  | 0.466   | 3,028,648,097   | 865,267,790          | 6,389,303             | 7,775,421       | -[ViewController measure_test:] |
| 16               | 11660         | 11660.0ms    | 10,222,736,283  | 23,092,928,577  | 0.443   | 3,031,941,684   | 928,635,058          | 5,766,600             | 7,315,329       | -[ViewController measure_test:] |
| 32               | 11958         | 11958.0ms    | 10,223,256,031  | 23,685,628,726  | 0.432   | 3,032,447,187   | 960,356,809          | 5,348,750             | 14,608,461      | -[ViewController measure_test:] |
| 64               | 12115         | 12115.0ms    | 10,236,558,206  | 24,075,146,071  | 0.425   | 3,034,526,133   | 975,149,471          | 5,700,351             | 69,104,502      | -[ViewController measure_test:] |
| 128              | 12189         | 12189.0ms    | 10,245,787,455  | 24,206,272,913  | 0.423   | 3,033,785,345   | 980,706,615          | 6,223,592             | 9,827,864       | -[ViewController measure_test:] |
| 256              | 12218         | 12218.0ms    | 10,226,406,147  | 24,272,967,961  | 0.421   | 3,031,664,566   | 985,991,929          | 6,364,799             | 32,554,141      | -[ViewController measure_test:] |


### Coxa (A11 - iOS 12.1)
| # Branch Targets | Total Samples | Running Time | Instructions    | Cycles          | IPC     | Branches        | MispredictedBranches | L1DataCacheLoadMisses | FED_IC_MISS_DEM | Symbol Name |
| ---------------- | ------------- | ------------ | --------------- | --------------- | ------- | --------------- | -------------------- | --------------------- | --------------- | ----------- |
| 1                | 853           | 853.0ms      | 10,008,814,551  | 2,021,638,431   | 4.951   | 3,001,472,487   | 4,485                | 584,923               | 15,306          | -[ViewController measure_test:] |
| 2                | 6956          | 6956.0ms     | 10,089,277,726  | 14,447,559,498  | 0.698   | 3,018,890,554   | 498,499,168          | 1,126,503             | 7,045           | -[ViewController measure_test:] |
| 4                | 9478          | 9478.0ms     | 10,123,132,872  | 19,685,601,046  | 0.514   | 3,025,883,078   | 747,112,259          | 1,506,540             | 62,290          | -[ViewController measure_test:] |
| 8                | 10616         | 10616.0ms    | 10,136,686,693  | 22,050,989,827  | 0.46    | 3,028,789,518   | 872,936,444          | 1,611,591             | 4,251           | -[ViewController measure_test:] |
| 16               | 11164         | 11164.0ms    | 10,141,636,535  | 23,190,371,236  | 0.437   | 3,029,831,026   | 937,173,869          | 1,685,966             | 4,820           | -[ViewController measure_test:] |
| 32               | 11422         | 11422.0ms    | 10,144,552,197  | 23,724,648,359  | 0.428   | 3,030,295,023   | 968,332,815          | 1,719,502             | 5,688           | -[ViewController measure_test:] |
| 64               | 11552         | 11552.0ms    | 10,145,426,877  | 23,995,317,999  | 0.423   | 3,030,487,331   | 984,347,832          | 1,716,636             | 4,845           | -[ViewController measure_test:] |
| 128              | 11613         | 11613.0ms    | 10,147,471,867  | 24,124,476,126  | 0.421   | 3,030,868,170   | 992,038,045          | 1,718,478             | 5,431           | -[ViewController measure_test:] |
| 256              | 11647         | 11647.0ms    | 10,143,746,914  | 24,192,837,098  | 0.419   | 3,030,003,797   | 995,962,971          | 1,746,886             | 14,889          | -[ViewController measure_test:] |


### Flourine (A12 - iOS 12.1)
| # Branch Targets | Total Samples | Running Time | Instructions    | Cycles          | IPC     | Branches        | MispredictedBranches | L1DataCacheLoadMisses | FED_IC_MISS_DEM | Symbol Name |
| ---------------- | ------------- | ------------ | --------------- | --------------- | ------- | --------------- | -------------------- | --------------------- | --------------- | ----------- |
| 1                | 808           | 808.0ms      | 9,985,270,010   | 2,026,304,201   | 4.928   | 2,994,187,374   | 9,122                | 222,949               | 25,099          | -[ViewController measure_test:] |
| 2                | 5322          | 5322.0ms     | 10,070,871,583  | 13,381,604,111  | 0.753   | 3,014,635,491   | 496,604,217          | 660,796               | 860             | -[ViewController measure_test:] |
| 4                | 7422          | 7422.0ms     | 10,096,695,426  | 18,661,747,582  | 0.541   | 3,020,045,048   | 749,205,131          | 867,683               | 1,457           | -[ViewController measure_test:] |
| 8                | 8417          | 8417.0ms     | 10,105,763,800  | 21,165,464,593  | 0.477   | 3,021,583,038   | 874,617,110          | 758,914               | 1,379           | -[ViewController measure_test:] |
| 16               | 8904          | 8904.0ms     | 10,112,880,523  | 22,391,192,880  | 0.452   | 3,022,977,117   | 937,865,421          | 664,258               | 1,898           | -[ViewController measure_test:] |
| 32               | 9135          | 9135.0ms     | 10,115,236,386  | 22,970,096,769  | 0.44    | 3,023,236,973   | 968,439,309          | 634,920               | 1,919           | -[ViewController measure_test:] |
| 64               | 9253          | 9253.0ms     | 10,113,400,344  | 23,265,585,570  | 0.435   | 3,022,853,525   | 984,518,104          | 630,684               | 1,874           | -[ViewController measure_test:] |
| 128              | 9308          | 9308.0ms     | 10,117,385,588  | 23,408,468,961  | 0.432   | 3,023,810,709   | 992,086,200          | 624,014               | 2,403           | -[ViewController measure_test:] |
| 256              | 9338          | 9338.0ms     | 10,113,452,290  | 23,482,317,848  | 0.431   | 3,022,867,176   | 995,957,140          | 623,260               | 1,803           | -[ViewController measure_test:] |

--------

## Summary
