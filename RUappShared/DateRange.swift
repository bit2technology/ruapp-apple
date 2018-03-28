//
//  DateRange.swift
//  RUappShared
//
//  Created by Igor Camilo on 16/03/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import Foundation

public typealias DateRange = Range<Date>

public extension Range where Bound == Date {

  static func today() throws -> Range<Bound> {

    let now = Date()
    let midnight = DateComponents(hour: 0, minute: 0, second: 0, nanosecond: 0)
    let oneDayBefore = DateComponents(day: -1)
    let calendar = Calendar.current

    guard
      let midnightTodayToTomorrow = calendar
        .nextDate(after: now, matching: midnight, matchingPolicy: .nextTime),
      let midnightYesterdayToToday = calendar
        .date(byAdding: oneDayBefore, to: midnightTodayToTomorrow)
      else {
        throw DateRangeError.calendarCantCalculateToday(now, calendar)
    }

    return midnightYesterdayToToday..<midnightTodayToTomorrow
  }

  static func fallbackToday() -> Range<Bound> {
    let now = Date()
    return now..<now.addingTimeInterval(86400)
  }

  func skipping(days: Int) throws -> Range<Bound> {

    let daysComponents = DateComponents(day: days)
    let calendar = Calendar.current

    guard
      let newStart = calendar
        .date(byAdding: daysComponents, to: lowerBound),
      let newFinish = calendar
        .date(byAdding: daysComponents, to: upperBound)
      else {
        throw DateRangeError.calendarCantSkipDays(self, calendar, days)
    }

    return newStart..<newFinish
  }
}

public enum DateRangeError: CustomNSError {
  case calendarCantCalculateToday(Date, Calendar)
  case calendarCantSkipDays(DateRange, Calendar, Int)

  public var errorUserInfo: [String : Any] {
    switch self {
    case .calendarCantCalculateToday(let date, let calendar):
      return ["Date": date.debugDescription,
              "Calendar": calendar.debugDescription]
    case .calendarCantSkipDays(let range, let calendar, let days):
      return ["LowerBound": range.lowerBound.debugDescription,
              "UpperBound": range.upperBound.debugDescription,
              "Calendar": calendar.debugDescription,
              "Days": days]
    }
  }
}
