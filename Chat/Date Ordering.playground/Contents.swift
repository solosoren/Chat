//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


let arrayOne = [1,2,3]
let arrayTwo = [3,2,1]
var thirdArray = [Int]()

for int in arrayOne {
    for number in arrayTwo {
        if int == number {
            thirdArray.append(int)
        }
    }
}

if arrayOne.count == thirdArray.count {
    print("Maybe")
} else {
    print("Still No")
}

if arrayOne == arrayTwo {
    print("Yes")
} else {
    print("No")
}


