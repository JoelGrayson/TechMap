//
//  MockData.swift
//  TechMap
//
//  Created by Joel Grayson on 6/27/25.
//

import Foundation

struct MockData {
    static let firebaseVM = FirebaseVM()
    static let companies = [
        Company(
            id: "d2767b84-b725-4cd1-b07e-ea6c65bcc4a1",
            name: "Apple",
            address: "Apple Park, 1 Apple Park Way, Cupertino, CA 95014",
            lat: 37.3287379,
            lng: -122.0078912,
            imageName: "apple.com.jpg",
            description: """
            Apple Inc. designs and sells iPhones, Macs, iPads, Apple Watch, and other premium consumer electronics. It pairs this hardware with proprietary software like iOS and macOS and services such as iCloud, Apple Music, and Apple TV+. Founded in 1976 by Steve Jobs, Steve Wozniak, and Ronald Wayne, the company pioneered the graphical-user-interface personal computer. Apple is publicly traded (AAPL) and is regularly ranked among the world’s most valuable companies. Its headquarters, Apple Park, is a circular, solar-powered campus often called “the spaceship.”
            """
        ),
        Company(
            id: "20598f52-d573-4c6c-9dc9-3102ac2bf5f4",
            name: "Google (Alphabet)",
            address: "1600 Amphitheatre Parkway, Mountain View, CA 94043",
            lat: 37.4220101,
            lng: -122.0847516,
            imageName: "google.com.jpg",
            description: """
            Alphabet is the parent company of Google and numerous other businesses ranging from self-driving cars (Waymo) to health tech (Verily). Google dominates global web search and digital advertising while also operating Android, YouTube, Google Cloud, and Google Maps. Founded in 1998 by Larry Page and Sergey Brin, the firm restructured as Alphabet in 2015 to separate its core internet services from longer-term “moonshots.” Advertising still provides the lion’s share of revenue, but cloud services and AI tools are the fastest-growing segments. Alphabet is one of the “Big Five” U.S. tech giants and trades under the tickers GOOGL and GOOG.
            """
        ),
        Company(
            id: "7e777c6a-eec2-42e7-a974-9df48cb42540",
            name: "Meta (Facebook)",
            address: "1601 Willow Road Menlo Park, CA 94025",
            lat: 37.482503,
            lng: -122.1479457,
            imageName: "meta.com.jpg",
            description: """
            Meta Platforms owns Facebook, Instagram, WhatsApp, Messenger, and Threads, serving billions of monthly users worldwide. Advertising on these social apps generates nearly all of the company’s revenue, making Meta one of the largest digital ad sellers. Rebranded from Facebook to Meta in 2021, the company invests heavily in virtual- and augmented-reality hardware through its Reality Labs division. Founder and CEO Mark Zuckerberg has positioned Meta to build the “metaverse,” an immersive, interconnected digital world. Despite rapid growth, the firm faces ongoing scrutiny over privacy, content moderation, and competition.
            """
        )
    ]
}

