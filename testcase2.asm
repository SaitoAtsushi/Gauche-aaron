; これは 1 から 5 までの平方和を計算するコードです。
        save 1, 5  ; 入力値は 5 とする
        save 3, 1
        save 4, 6
loop    decr 1, label3
        incr 1
        save 5, pc
        incr 5, 2
        decr -1, square
        incr 0, [6]
        decr 1, label3
        decr -1, loop
label3  halt
square  save 9, [[3]]
        save 2, 9
        save 7, [5]
        save 5, pc
        incr 5, 2
        decr -1, mul
        decr -1, [7]
add     save [4], [[2]]
        incr [4], [[3]]
        decr -1, [5]
mul     save [4], 0
        save 8, [[3]]
label1  decr [3], label2
        incr [4], [[2]]
        decr -1, label1
label2  save [3], [8]
        decr -1, [5]
