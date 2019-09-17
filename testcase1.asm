; これは階乗を計算するコードです。
        save  1, 5 ; 入力値は 5
        save  2, 6
        save  3, 7
        save  0, 1
loop    decr  1, label3
        save  7, [1]
        incr  7, 1
        save  5, pc
        incr  5, 2
        decr -1, mul
        save  0, [6]
        decr -1, loop
mul     save [2], 0
        save  8, [[3]]
label1  decr [3], label2
        incr [2], [[4]]
        decr -1, label1
label2  save [3], [8]
        decr -1, [5]
label3  halt
