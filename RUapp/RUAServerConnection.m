//
//  RUAServerConnection.m
//  RUapp
//
//  Created by Igor Camilo on 18/06/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAServerConnection.h"

NSString *const RUASavedVotesKey = @"SavedVotes";

@implementation RUAResultInfo

// MARK: NSObject

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[RUAResultInfo class]]) {
        RUAResultInfo *resultInfo = object;
        if (self.restaurant != resultInfo.restaurant ||
            ![self.date isEqualToDate:resultInfo.date] ||
            self.meal != resultInfo.meal ||
            self.votesTotal != resultInfo.votesTotal ||
            ![self.votesText isEqualToArray:resultInfo.votesText] ||
            ![self.votesProgress isEqualToArray:resultInfo.votesProgress] ||
            ![self.reasons isEqualToArray:resultInfo.reasons]) {
            return NO;
        } else {
            return YES;
        }
    }
    return [super isEqual:object];
}

@end

@implementation RUAServerConnection

// MARK: Methods

+ (void)performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // Get saved votes
    NSMutableArray *savedVotes = [[[NSUserDefaults standardUserDefaults] arrayForKey:RUASavedVotesKey] mutableCopy];
    
    // If there is no vote, return No Data.
    if (!savedVotes.count) {
        if (completionHandler) {
            completionHandler(UIBackgroundFetchResultNoData);
        }
        return;
    }
    
    // Otherwise, create session and URL request and send votes.
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[RUAAppDelegate serverVoteURL]];
    urlRequest.HTTPMethod = @"POST";
    [self recursiveFetchWithArray:savedVotes session:urlSession request:urlRequest completionHandler:completionHandler];
}

+ (void)requestMenuForWeekWithCompletionHandler:(void (^)(NSDictionary *weekMenu, NSString *localizedMessage))handler
{
    // Get week number.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorianCalendar.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    NSDateComponents *dateComponents = [gregorianCalendar components:NSCalendarUnitWeekday|NSCalendarUnitWeekOfYear fromDate:[RUAAppDelegate sharedAppDelegate].date];
    
    // Generate request string (adjust week to start on monday).
    if (dateComponents.weekday <= 1) {
        dateComponents.weekOfYear--;
    }
    NSString *requestString = [NSString stringWithFormat:@"tag=9$UFJF_%ld", (long)dateComponents.weekOfYear];
    
    // Request with shared session configuration.
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[RUAAppDelegate serverURL]];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    [[urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *networkError) {
        // Verify network error.
        if (networkError) {
            NSLog(@"Menu error: %@", networkError);
            
            // Main thread
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                handler(nil, NSLocalizedString(@"Couldn't download menu", @"Menu download error message"));
            }];
            return;
        }
        
        // Serialize JSON and get return string.
        NSArray *serializationResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        // Separete main components if it is a valid menu.
        NSArray *mainComponents = [serializationResult.lastObject componentsSeparatedByString:@"$"];
        if (mainComponents.count <= 1) { // It means there was a server error or that there is no menu.
            // Main thread
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                handler(nil, NSLocalizedString(@"Menu not available for this week", @"Menu availability error message"));
            }];
            return;
        }
        NSMutableArray *weekMenu = [NSMutableArray arrayWithCapacity:mainComponents.count];
        for (NSString *mainComponent in mainComponents) {
            [weekMenu addObject:[mainComponent componentsSeparatedByString:@"_"]];
        }
        
        // Main thread
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            handler(@{@"WeekOfYear": @(dateComponents.weekOfYear), @"Menu": weekMenu}, nil);
        }];
    }] resume];
}

+ (void)requestResultsWithCompletionHandler:(void (^)(NSArray *results, NSString *localizedMessage))handler
{
    // Options
    NSDate *now = [RUAAppDelegate sharedAppDelegate].date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy";
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"pt_BR"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    RUAMeal lastMeal = [RUAAppDelegate lastMealForDate:&now];
    NSString *options = [NSString stringWithFormat:@"%@_%lu", [dateFormatter stringFromDate:now], (unsigned long)(lastMeal + 1)];
    
    // Request
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[RUAAppDelegate serverURL]];
    urlRequest.HTTPMethod = @"POST";
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:2];
    NSMutableArray *restaurants = [NSMutableArray arrayWithObjects:@"UFJF1", @"UFJF2", nil];
    
    [self recursiveResultsWithArray:results locals:restaurants options:options date:now meal:lastMeal session:urlSession request:urlRequest completionHandler:handler];
}

+ (void)sendVoteWithRestaurant:(RUARestaurant)restaurant rating:(RUARating)vote reason:(NSArray *)reason completionHandler:(void (^)(NSDate *voteDate, NSString *localizedMessage))handler
{
    NSDate *now = [RUAAppDelegate sharedAppDelegate].date;
    RUAMeal mealForNow = [RUAAppDelegate mealForDate:now];
    if (mealForNow == RUAMealNone) {
        handler(nil, NSLocalizedString(@"Sorry, there is no vote open now", @"Vote availability error message"));
    }
    
    // Components of vote server request.
    NSMutableArray *stringComponents = [NSMutableArray arrayWithCapacity:6];
    
    // Restaurant and tag to server
    [stringComponents addObject:[NSString stringWithFormat:@"tag=6$UFJF%lu", (unsigned long)restaurant + 1]];
    
    // Date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy";
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"pt_BR"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    [stringComponents addObject:[dateFormatter stringFromDate:now]];
    
    // Meal
    [stringComponents addObject:[NSString stringWithFormat:@"%lu", (unsigned long)mealForNow + 1]];
    
    // Vote
    [stringComponents addObject:[NSString stringWithFormat:@"%lu", (unsigned long)vote + 1]];
    
    // Reason
    if (reason.count > 0) {
        NSMutableArray *reasonComponents = [NSMutableArray arrayWithCapacity:reason.count];
        for (NSNumber *reasonNumber in reason) {
            [reasonComponents addObject:[NSString stringWithFormat:@"%02lu", (unsigned long)[reasonNumber unsignedIntegerValue] + 1]];
        }
        [stringComponents addObject:[reasonComponents componentsJoinedByString:@"."]];
    } else {
        [stringComponents addObject:@"00"];
    }
    
    // Device ID
    [stringComponents addObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString]]; //@(arc4random()).description;
    
    // Request
    NSString *requestString = [stringComponents componentsJoinedByString:@"_"];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[RUAAppDelegate serverVoteURL]];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    [[urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *networkError) {
        // Verify network error.
        if (networkError) {
            NSLog(@"Vote error: %@", networkError);
            
            // Save vote for send later
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray *savedVotes = [[standardUserDefaults arrayForKey:RUASavedVotesKey] mutableCopy];
            if (!savedVotes) {
                savedVotes = [NSMutableArray array];
            }
            [savedVotes addObject:urlRequest.HTTPBody];
            [standardUserDefaults setObject:savedVotes forKey:RUASavedVotesKey];
            [standardUserDefaults synchronize];
            
            // Main thread
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                handler(now, NSLocalizedString(@"Ooops, we couldn't connect. Your vote will be sent as soon as possible.", @"Vote offline computed message"));
            }];
            return;
        }
        
        // Serialize JSON and get return string.
        NSArray *serializationResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        // Separete main components and verify if it is a valid response.
        NSArray *mainComponents = [serializationResult.lastObject componentsSeparatedByString:@"#"];
        if (mainComponents.count < 5) { // Already voted or something went wrong.
            // Main thread
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                handler(nil, NSLocalizedString(@"Ooops, something went wrong", @"General error message"));
            }];
            return;
        }
        
        // Main thread
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            handler(now, NSLocalizedString(@"Thank you! Vote computed", @"Vote computed message"));
        }];
    }] resume];
}

// MARK: Helper methods

/**
 * Helper recursive method to send saved (offline) votes.
 */
+ (void)recursiveFetchWithArray:(NSMutableArray *)savedVotes session:(NSURLSession *)session request:(NSMutableURLRequest *)request completionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // If there is votes yet to be sent, modify request's HTTP body and call this method again.
    if (savedVotes.count) {
        request.HTTPBody = savedVotes.lastObject;
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                if (completionHandler) {
                    completionHandler(UIBackgroundFetchResultFailed);;
                }
            } else {
                [savedVotes removeLastObject];
                NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                [standardUserDefaults setObject:savedVotes forKey:RUASavedVotesKey];
                [standardUserDefaults synchronize];
                [self recursiveFetchWithArray:savedVotes session:session request:request completionHandler:completionHandler];
            }
        }] resume];
    } else {
        if (completionHandler) {
            completionHandler(UIBackgroundFetchResultNewData);;
        }
    }
}

/**
 * Helper recursive method to download results for all restaurants.
 */
+ (void)recursiveResultsWithArray:(NSMutableArray *)results locals:(NSMutableArray *)locals options:(NSString *)options date:(NSDate *)date meal:(RUAMeal)meal session:(NSURLSession *)session request:(NSMutableURLRequest *)request completionHandler:(void (^)(NSArray *results, NSString *localizedMessage))handler
{
    if (locals.count) {
        NSString *requestString = [NSString stringWithFormat:@"tag=8$%@_%@_1_00_id", locals.firstObject, options];
        request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *networkError) {
            // Verify network error.
            if (networkError) {
                NSLog(@"Results error: %@", networkError);
                
                // Main thread
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    handler(nil, NSLocalizedString(@"Ooops, we couldn't connect", @"Results download error message"));
                }];
                [locals removeAllObjects];
                return;
            }
            
            // Serialize JSON and get return string.
            NSArray *serializationResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            // Separete main components and verify if it is a valid response.
            NSMutableArray *mainComponents = [[serializationResult.lastObject componentsSeparatedByString:@"#"] mutableCopy];
            if (mainComponents.count < 5) {
                // Main thread
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    handler(nil, NSLocalizedString(@"Ooops, something went wrong", @"General error message"));
                }];
                [locals removeAllObjects];
                return;
            }
            
            // Object with result of one local.
            RUAResultInfo *result = [[RUAResultInfo alloc] init];
            
            // Get overview information.
            NSString *overview = mainComponents.firstObject;
            [mainComponents removeObjectAtIndex:0];
            NSArray *overviewComponents = [overview componentsSeparatedByString:@"$"];
            NSArray *overviewInformation = [[overviewComponents firstObject] componentsSeparatedByString:@"_"];
            // Restaurant
            NSString *restaurantString = [overviewInformation firstObject];
            if ([restaurantString isEqualToString:@"UFJF1"]) {
                result.restaurant = RUARestaurantJuizDeForaDowntown;
            } else if ([restaurantString isEqualToString:@"UFJF2"]) {
                result.restaurant = RUARestaurantJuizDeForaCampus;
            } else {
                result.restaurant = RUARestaurantNone;
            }
            // Date
            result.date = date;
            // Meal
            result.meal = meal;
            // Votes
            CGFloat votesTotal = 0, votesBiggest = 0;
            for (NSUInteger i = 1; i < 5; i++) {
                CGFloat vote = [overviewComponents[i] floatValue];
                votesTotal += vote;
                if (vote > votesBiggest) {
                    votesBiggest = vote;
                }
            }
            result.votesTotal = (NSUInteger)votesTotal;
            NSMutableArray *votesText = [NSMutableArray arrayWithCapacity:4];
            for (NSUInteger i = 1; i < 5; i++) {
                [votesText addObject:@([overviewComponents[i] floatValue] / votesTotal)];
            }
            result.votesText = votesText;
            NSMutableArray *votesProgress = [NSMutableArray arrayWithCapacity:4];
            for (NSUInteger i = 1; i < 5; i++) {
                [votesProgress addObject:@([overviewComponents[i] floatValue] / votesBiggest)];
            }
            result.votesProgress = votesProgress;
            // Reason
            NSArray *menuList = [[RUAAppDelegate sharedAppDelegate].menuTableViewController menuForMeal:result.meal];
            if (!menuList) {
                menuList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DishesList" ofType:@"plist"]]; // Dishes list
            }
            NSMutableArray *reasons = [NSMutableArray arrayWithCapacity:4];
            for (NSString *string in mainComponents) {
                NSArray *reasonComponents = [string componentsSeparatedByString:@"$"];
                CGFloat reasonTotal = 0, reasonBiggest = 0;
                for (NSString *reasonString in reasonComponents) {
                    CGFloat reasonCount = [reasonString floatValue];
                    reasonTotal += reasonCount;
                    if (reasonCount > reasonBiggest) {
                        reasonBiggest = reasonCount;
                    }
                }
                if (reasonTotal) {
                    NSMutableArray *reason = [NSMutableArray arrayWithCapacity:7];
                    [reasonComponents enumerateObjectsUsingBlock:^(NSString *countString, NSUInteger idx, BOOL *stop) {
                        if ([countString floatValue] == reasonBiggest) {
                            [reason addObject:menuList[idx]];
                        }
                    }];
                    [reasons addObject:@{@"dishes": [reason componentsJoinedByString:@";\n"], @"percent": @(reasonBiggest / reasonTotal * reason.count)}];
                } else {
                    [reasons addObject:@{}];
                }
            }
            result.reasons = reasons;
            
            [results addObject:result];
            [locals removeObjectAtIndex:0];
            
            [self recursiveResultsWithArray:results locals:locals options:options date:date meal:meal session:session request:request completionHandler:handler];
        }] resume];
    } else {
        if (results.count >= 2) {
            // Main thread
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                handler(results, nil);
            }];
        }
    }
}

@end
