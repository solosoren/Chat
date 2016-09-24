//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

let array1 = ["A", "B", "C", "D", "E"]
let array2 = ["B", "E", "C", "A", "D"]
var sortedArray = [String]()

for object in array1 {
    for string in array2 {
        if string == object {
            sortedArray += [string]
        }
    }
}

print(sortedArray)


var names: String = "Soren Nelson, Shawn Nelson"
let array = names.components(separatedBy: ", ")
print(array.count)











