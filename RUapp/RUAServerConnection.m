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
            //![self.date isEqualToDate:resultInfo.date] || // Date is not compared.
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"Restaurant: %zd, date: %@, meal: %zd, total of votes: %zd, votes text: %@, votes progress: %@, reasons: %@", self.restaurant, self.date, self.meal, self.votesTotal, self.votesText, self.votesProgress, self.reasons];
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
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[RUAAppDelegate serverMenuURL]];
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
    dateFormatter.dateFormat = @"yyyy.MM.dd";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    RUAMeal lastMeal = [RUAAppDelegate lastMealForDate:&now];

    // Request
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[RUAAppDelegate serverResultsURL]];
    urlRequest.HTTPMethod = @"POST";
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:2];
    NSMutableArray *restaurants = [NSMutableArray arrayWithObjects:@(RUARestaurantJuizDeForaDowntown), @(RUARestaurantJuizDeForaCampus), nil];
    
    [self recursiveResultsWithArray:results locals:restaurants dateFormatter:dateFormatter date:now meal:lastMeal session:urlSession request:urlRequest completionHandler:handler];
}

+ (void)sendVoteWithRestaurant:(RUARestaurant)restaurant rating:(RUARating)vote reason:(NSArray *)reason completionHandler:(void (^)(NSDate *voteDate, NSString *localizedMessage))handler
{
    NSDate *now = [RUAAppDelegate sharedAppDelegate].date;
    RUAMeal mealForNow = [RUAAppDelegate mealForDate:now];
    if (mealForNow == RUAMealNone) {
        handler(nil, NSLocalizedString(@"Sorry, there is no vote open now", @"Vote availability error message"));
    }
    
    // String of vote server request.
    NSMutableString *HTTPBodyString = [NSMutableString stringWithString:@"voto={"];
    
    // Restaurant
    [HTTPBodyString appendFormat:@"\"ID Instituição\":1,\"ID Restaurante\":%zd,", restaurant + 1];
    // TODO: Institution number
    
    // Date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy.MM.dd";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    [HTTPBodyString appendFormat:@"\"Data\":\"%@\",", [dateFormatter stringFromDate:now]];
    
    // Meal
    [HTTPBodyString appendFormat:@"\"Refeição\":%zd,", mealForNow + 1];
    
    // Vote
    [HTTPBodyString appendFormat:@"\"Voto\":%zd,", vote + 1];
    
    // Reason
    for (NSUInteger i = 0; i < 7; i++) {
        [HTTPBodyString appendFormat:@"\"Explica %zd\": %zd,", i + 1, [reason containsObject:@((RUADish)i)] ? 1 : 0];
    }

    // Device ID
    [HTTPBodyString appendFormat:@"\"ID Dispositivo\":\"%@\",", [[[UIDevice currentDevice] identifierForVendor] UUIDString]]; //@(arc4random()).description;

    // System info
    [HTTPBodyString appendFormat:@"\"Sistema Operacional\":\"%@\",\"Versão SO\":\"%@\"", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
    
    // Request
    [HTTPBodyString appendString:@"}"];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[RUAAppDelegate serverVoteURL]];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = [HTTPBodyString dataUsingEncoding:NSUTF8StringEncoding];
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
        NSDictionary *serializationResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        // Separete main components and verify if it is a valid response.
        switch ([serializationResult[@"Resultado"] unsignedIntegerValue]) {

            case 0: { // Succeeded
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    handler(now, NSLocalizedString(@"Thank you! Vote computed", @"Vote computed message"));
                }];
            } break;

            case 1: { // Already voted
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    handler(now, NSLocalizedString(@"Sorry, you can vote only once", @"Already voted message"));
                }];
            } break;

            default: { // General error
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    handler(nil, NSLocalizedString(@"Ooops, something went wrong", @"General error message"));
                }];
            } break;
        }
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
+ (void)recursiveResultsWithArray:(NSMutableArray *)results locals:(NSMutableArray *)locals dateFormatter:(NSDateFormatter *)dateFormatter date:(NSDate *)date meal:(RUAMeal)meal session:(NSURLSession *)session request:(NSMutableURLRequest *)request completionHandler:(void (^)(NSArray *results, NSString *localizedMessage))handler
{
    if (locals.count) {
        NSMutableString *HTTPBodyString = [NSMutableString stringWithString:@"voto={\"ID Instituição\":1,"];

        [HTTPBodyString appendFormat:@"\"ID Restaurante\":\"%zd\",", [locals.firstObject unsignedIntegerValue] + 1];

        [HTTPBodyString appendFormat:@"\"Refeição\":\"%zd\",", meal + 1];

        [HTTPBodyString appendFormat:@"\"Data\":\"%@\"", [dateFormatter stringFromDate:date]];

        [HTTPBodyString appendString:@"}"];




        request.HTTPBody = [HTTPBodyString dataUsingEncoding:NSUTF8StringEncoding];
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
            NSDictionary *serializationResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

            // Object with result of one local.
            RUAResultInfo *result = [[RUAResultInfo alloc] init];
            
            result.restaurant = (NSUInteger)[serializationResult[@"ID Restaurante"] integerValue] - 1;
            // Date
            result.date = date;
            // Meal
            result.meal = meal;
            // Votes
            CGFloat votesTotal = 0, votesBiggest = 0;
            for (NSUInteger i = 1; i < 5; i++) {
                CGFloat vote = [serializationResult[[NSString stringWithFormat:@"Voto %zd", i]] floatValue];
                votesTotal += vote;
                if (vote > votesBiggest) {
                    votesBiggest = vote;
                }
            }
            result.votesTotal = (NSUInteger)votesTotal;
            NSMutableArray *votesText = [NSMutableArray arrayWithCapacity:4];
            for (NSUInteger i = 1; i < 5; i++) {
                [votesText addObject:@([serializationResult[[NSString stringWithFormat:@"Voto %zd", i]] floatValue] / votesTotal)];
            }
            result.votesText = votesText;
            NSMutableArray *votesProgress = [NSMutableArray arrayWithCapacity:4];
            for (NSUInteger i = 1; i < 5; i++) {
                [votesProgress addObject:@([serializationResult[[NSString stringWithFormat:@"Voto %zd", i]] floatValue] / votesBiggest)];
            }
            result.votesProgress = votesProgress;
            // Reason
            NSArray *menuList = [[RUAAppDelegate sharedAppDelegate].menuTableViewController menuForMeal:result.meal];
            if (!menuList) {
                menuList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DishesList" ofType:@"plist"]]; // Dishes list
            }
            NSMutableArray *reasons = [NSMutableArray arrayWithCapacity:4];
            for (NSUInteger i = 1; i < 5; i++) {
                CGFloat reasonTotal = 0, reasonBiggest = 0;
                for (NSUInteger j = 1; j < 8; j++) {
                    CGFloat reasonCount = [serializationResult[[NSString stringWithFormat:@"Voto %zd Explica %zd", i, j]] floatValue];
                    reasonTotal += reasonCount;
                    if (reasonCount > reasonBiggest) {
                        reasonBiggest = reasonCount;
                    }
                }
                if (reasonTotal) {
                    NSMutableArray *reason = [NSMutableArray arrayWithCapacity:7];
                    for (NSUInteger j = 1; j < 8; j++) {
                        if ([serializationResult[[NSString stringWithFormat:@"Voto %zd Explica %zd", i, j]] floatValue] == reasonBiggest) {
                            [reason addObject:menuList[j]];
                        }
                    };
                    [reasons addObject:@{@"dishes": [reason componentsJoinedByString:@";\n"], @"percent": @(reasonBiggest / reasonTotal * reason.count)}];
                } else {
                    [reasons addObject:@{}];
                }
            }
            result.reasons = reasons;

            [results addObject:result];
            [locals removeObjectAtIndex:0];
            
            [self recursiveResultsWithArray:results locals:locals dateFormatter:dateFormatter date:date meal:meal session:session request:request completionHandler:handler];
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
