//
//  indirect_branch_test.s
//  test_app
//
//  Created by Andy White on 1/4/19.
//  Copyright © 2019 Andy White. All rights reserved.
//

.text
.global _indirectBranchTest

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

