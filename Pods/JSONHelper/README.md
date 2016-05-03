
#JSONHelper [![CocoaPods](https://img.shields.io/cocoapods/l/JSONHelper.svg)](https://github.com/isair/JSONHelper/blob/master/LICENSE) ![CocoaPods](https://img.shields.io/cocoapods/p/JSONHelper.svg)

[![Build Status](https://travis-ci.org/isair/JSONHelper.svg?branch=master)](https://travis-ci.org/isair/JSONHelper)
[![CocoaPods](https://img.shields.io/cocoapods/v/JSONHelper.svg)](https://cocoapods.org/pods/JSONHelper)
[![Stories in Ready](https://badge.waffle.io/isair/JSONHelper.png?label=ready&title=Ready)](https://waffle.io/isair/JSONHelper)
[![Gratipay](https://img.shields.io/gratipay/bsencan91.svg)](https://gratipay.com/bsencan91/)
[![Gitter](https://badges.gitter.im/JOIN CHAT.svg)](https://gitter.im/isair/JSONHelper?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Lightning fast JSON deserialization for iOS &amp; OS X written in Swift. A much improved version, and a rewrite, is under development in branch [dev-2.0.0](https://github.com/isair/JSONHelper/tree/dev-2.0.0) and any contributions to it are welcome as my personal time is currently very limited.

##Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Operator List](#operator-list)
4. [Simple Tutorial](#simple-tutorial)
5. [Assigning Default Values](#assigning-default-values)
6. [NSDate and NSURL Deserialization](#nsdate-and-nsurl-deserialization)
7. [JSON String Deserialization](#json-string-deserialization)

##Introduction

JSONHelper is a library written to make sure that deserializing data obtained from an API is as easy as possible. It doesn't depend on any networking libraries, and works equally well with any of them.

__Requires iOS 7 or later and Xcode 6.1+__

##Installation

###[Carthage](https://github.com/Carthage/Carthage#installing-carthage)

Add the following line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

```
github "isair/JSONHelper"
```

Then do `carthage update`. After that, add the framework to your project.

###[Cocoapods](https://github.com/CocoaPods/CocoaPods)

Add the following line in your `Podfile`.

```
pod "JSONHelper"
```	

###Drag & Drop

You can also add [JSONHelper.swift](https://raw.githubusercontent.com/isair/JSONHelper/master/JSONHelper/JSONHelper.swift) directly into your project.

##Basic Tutorial

First of all I'm going to assume you use [AFNetworking](https://github.com/AFNetworking/AFNetworking) as your networking library; for simplicity. Let's say we have an endpoint at __http://yoursite.com/movies/__ which gives the following response when a simple __GET__ request is sent to it.

```json
{
  "movies": [
    {
      "name": "Filth",
      "release_date": "2014-05-30",
      "cast": {
        "Bruce": "James McAvoy",
        "Lennox": "Jamie Bell"
      }
    },
    {
      "name": "American Psycho",
      "release_date": "2000-04-14",
      "cast": {
        "Patrick Bateman": "Christian Bale",
        "Timothy Bryce": "Justin Theroux"
      }
    }
  ]
}
```

From this response it is clear that we have a book model similar to the implementation below.

```swift
struct Movie {
  var name: String?
  var releaseDate: NSDate?
  var cast: [String: String]?
}
```

We now have to make it extend the protocol __Deserializable__ and implement the __required init(data: [String: AnyObject])__ initializer and use our deserialization operator (`<--`) in it. The complete model should look like this:

```swift
struct Movie: Deserializable {
  var name: String?
  var releaseDate: NSDate?
  var cast: [String: String]?

  init(data: [String: AnyObject]) {
    name <-- data["name"]
    releaseDate <-- (data["release_date"], "yyyy-MM-dd") // Refer to the next section for more info.
    cast <-- data["cast"]
  }
}
```

And finally, requesting and deserializing the response from our endpoint becomes as easy as the following piece of code.

```swift
AFHTTPRequestOperationManager().GET(
  "http://yoursite.com/movies/"
  parameters: nil,
  success: { operation, data in
    var movies: [Movie]?
    movies <-- data["movies"]
    
    if let movies = movies {
      // Response contained a movies array, and we deserialized it. Do what you want here.
    } else {
      // Server gave us a response but there was no "movies" key in it, so the movies variable
      // is equal to nil. Do some error handling here.
    }
  },
  failure: { operation, error in
    // Handle error.
})
```

##Assigning Default Values

You can easily assign default values to variables in cases where you want them to have a certain value when deserialization fails.

````swift
struct User: Deserializable {
  var name = "Guest"
  
  init(data: [String: AnyObject]) {
    name <-- data["name"]
  }
}
````

##NSDate and NSURL Deserialization

NSURL deserialization works very much like a primitive type deserialization.

````swift
let website: NSURL?
let imageURLs: [NSURL]?

website <-- "http://mywebsite.com"
imageURLs <-- ["http://mywebsite.com/image.png", "http://mywebsite.com/anotherImage.png"]
````

NSDate deserialization however, requires a format to be provided most of the time.

````swift
let meetingDate: NSDate?
let partyDates: [NSDate]?

meetingDate <-- ("2014-09-18", "yyyy-MM-dd")
partyDates <-- (["2014-09-19", "2014-09-20"], "yyyy-MM-dd")

let myDayOff: NSDate?
myDayOff <-- 1414172803 // You can also use unix timestamps.
````

##JSON String Deserialization

You can deserialize instances and arrays of instances directly from a JSON string as well. Here is a quick example.

````swift
struct Person: Deserializable {
  var name = ""

  init(data: [String: AnyObject]) {
    name <-- data["name"]
  }
}

let jsonString = "[{\"name\": \"Rocket Raccoon\"}, {\"name\": \"Groot\"}]"
var people = [Person]()

people <-- jsonString

for person in people {
  println(person.name)
}
````
