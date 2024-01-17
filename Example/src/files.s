        .text

        .align  2
fileName1:
        .asciz  "example.bin"
fileName2:
        .asciz  "example.bin"
fileName3:
        .asciz  "example.bin"
fileName4:
        .asciz  "example.bin"
fileName5:
        .asciz  "example.bin"
fileName6:
        .asciz  "example.bin"
fileName7:
        .asciz  "example.bin"

        .align  131072
file1:
        .incbin "example.bin"
fileEnd1:

        .align  131072
file2:
        .incbin "example.bin"
fileEnd2:

        .align  131072
file3:
        .incbin "example.bin"
fileEnd3:

        .align  131072
file4:
        .incbin "example.bin"
fileEnd4:

        .align  131072
file5:
        .incbin "example.bin"
fileEnd5:

        .align  131072
file6:
        .incbin "example.bin"
fileEnd6:

        .align  131072
file7:
        .incbin "example.bin"
fileEnd7:

        .align  131072

        
        .global fileName
fileName:
        .long   fileName1
        .long   fileName2
        .long   fileName3
        .long   fileName4
        .long   fileName5
        .long   fileName6
        .long   fileName7

        .global fileSize
fileSize:
        .long   fileEnd1 - file1
        .long   fileEnd2 - file2
        .long   fileEnd3 - file3
        .long   fileEnd4 - file4
        .long   fileEnd5 - file5
        .long   fileEnd6 - file6
        .long   fileEnd7 - file7

        .global filePtr
filePtr:
        .long   file1
        .long   file2
        .long   file3
        .long   file4
        .long   file5
        .long   file6
        .long   file7

        .align  4
