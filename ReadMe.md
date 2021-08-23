Interview coding test
8/23/2021

Write a macOS CLI Tool to process equations input from the console

The command-line program is writen in Swift and will take operations on fractions as an input and produce a fractional result.

Legal operators are *, /, +, - (multiply, divide, add, subtract)

Operands and operators should be separated by one or more spaces

Mixed numbers will be represented by whole_numerator/denominator. e.g. "3_1/4"

Improper fractions and whole numbers are also allowed as operands 

Example run:

? 1/2 * 3_3/4

= 1_7/8

? 2_3/8 + 9/8

= 3_1/2

Note: Only one operation is processed per equation. Otherwise the program would have to deal with precedence of operations, (i.e. multiply and divide over add and subtract) which is does not. 

The CLI Tool is built with Xcode and the tool is copied to ${PROJECT_DIR}/bin at build time.

To run in Terminal:

cd ${PROJECT_DIR}
bin/FBC

