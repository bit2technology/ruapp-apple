//
//  RUAServerConnection.m
//  RUapp
//
//  Created by Igor Camilo on 18/06/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAServerConnection.h"
#import "RUAAppDelegate.h"

NSString *const serverURLString = @"http://titugoru2.appspot.com/getvalue";

@interface RUAResultInfo ()

@property (assign, nonatomic) RUARestaurant restaurant;
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) RUAMeal meal;
@property (strong, nonatomic) NSArray *votes;

@end

@implementation RUAResultInfo

@end

@implementation RUAServerConnection

+ (void)sendVoteWithRestaurant:(RUARestaurant)restaurant vote:(RUARating)vote reason:(NSArray *)reason completionHandler:(void (^)(NSDate *voteDate, NSError *error))handler
{
    // Components of vote server request.
    NSMutableArray *stringComponents = [NSMutableArray arrayWithCapacity:6];
    
    // Restaurant and tag to server
    [stringComponents addObject:[NSString stringWithFormat:@"tag=6$UFJF%lu", (unsigned long)restaurant + 1]];
    
    // Date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy";
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"pt_BR"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    NSDate *now = [NSDate date];
    [stringComponents addObject:[dateFormatter stringFromDate:now]];
    
    // Meal
    [stringComponents addObject:[NSString stringWithFormat:@"%lu", (unsigned long)[RUAAppDelegate mealForDate:now] + 1]];
    
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
#warning Fix Device ID.
    dateFormatter.dateFormat = @"dd.MM.yyyy.HH.mm.ss";
    [stringComponents addObject:[dateFormatter stringFromDate:now]];//[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    
    // Request
    NSString *requestString = [stringComponents componentsJoinedByString:@"_"];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverURLString]];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    [[urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *networkError) {
        // Verify network error.
        if (networkError) {
            // Main thread
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                handler(nil, networkError);
            }];
            return;
        }
        
        // Serialize JSON and get return string.
        NSError *serializationError;
        NSArray *serializationResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&serializationError];
        // Verify serialization error.
        if (serializationError) {
            // Main thread
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                handler(nil, serializationError);
            }];
            return;
        }
        
        // Separete main components and verify if it is a valid response.
        NSArray *mainComponents = [serializationResult.lastObject componentsSeparatedByString:@"#"];
        if (mainComponents.count < 5) { // Already voted.
            // Main thread
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                handler(nil, nil);
            }];
            return;
        }
        
        // Main thread
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            handler(now, nil);
        }];
    }] resume];
}

/*
 Resultado de votação:
 UFJF2_03.05.2014_2 8 7 3 5
 3 0 2 2 0 1 0
 3 2 0 0 0 0 0
 0 0 0 1 1 0 1
 0 0 2 2 1 0 1
 
 Algoritmo:
  Separar a string nas “#”, formando uma lista.
 
 Item 0 da lista: (UFJF2_03.05.2014_2$8$7$3$5)
 o o o o o
 
 Separar string nos “$”, formando outra lista
 Item 0 da lista = votos muito bom
 Item 1 da lista = votos bom
 Item 2 da lista = votos ruim
 Item 3 a lista = votos muito ruim
 
  Item 1 ao 4 da lista: (3$0$2$2$0$1$0)
 
 o Separar string nos “$”, formando outra lista
 o Item 0 da lista: justificativa do prato principal
 o Item 1 da lista: justificativa da opção vegetariana
 o E assim por diante...
 o Obs: a ordem é: Prato principal, opção vegetariana, guarnição, massa,
 acompanhamento, salada e sobremesa
 */

+ (void)requestResultsWithCompletionHandler:(void (^)(RUAResultInfo *results, NSError *error))handler
{
    // Background thread
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        // Download result string.
        NSString *resultsString = @"UFJF2_03.05.2014_2$8$7$3$5#3$0$2$2$0$1$0#3$2$0$0$0$0$0#0$0$0$1$1$0$1#0$0$2$2$1$0$1";
        
        // Object with results.
        RUAResultInfo *results = [[RUAResultInfo alloc] init];
        
        // Separete main components.
        NSMutableArray *mainComponents = [[resultsString componentsSeparatedByString:@"#"] mutableCopy];
        
        // Get overview information.
        NSString *overview = [mainComponents firstObject];
        [mainComponents removeObjectAtIndex:0];
        NSArray *overviewComponents = [overview componentsSeparatedByString:@"$"];
        NSArray *overviewInformation = [[overviewComponents firstObject] componentsSeparatedByString:@"_"];
        // Restaurant
        NSString *restaurantString = [overviewInformation firstObject];
        if ([restaurantString isEqualToString:@"UFJF1"]) {
            results.restaurant = RUARestaurantJuizDeForaDowntown;
        } else if ([restaurantString isEqualToString:@"UFJF2"]) {
            results.restaurant = RUARestaurantJuizDeForaCampus;
        } else {
            results.restaurant = RUARestaurantNone;
        }
        // Date
        NSString *dateString = overviewInformation[1];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
        results.date = [dateFormatter dateFromString:dateString];
        // Meal
        results.meal = (RUAMeal)([overviewInformation[2] integerValue] - 1);
        // Votes
        NSMutableArray *votesHelper = [NSMutableArray arrayWithCapacity:4];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        for (NSUInteger i = 1; i < 5; i++) {
            [votesHelper addObject:[numberFormatter numberFromString:overviewComponents[i]]];
        }
        results.votes = votesHelper;
        
        NSLog(@"results: %@", results);
        
        // Main thread
        //[[NSOperationQueue mainQueue] addOperationWithBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            handler(results, [[NSError alloc] init]);
        });
        
//        for (NSUInteger i = 0; i < mainComponents.count; i++) {
//            // Separate secondary components.
//            NSArray *secondaryComponents = [mainComponents[i] componentsSeparatedByString:@"$"];
//            if (i == 0) {
//                // First main component.
//                for (NSUInteger j = 0; j < secondaryComponents.count; j++) {
//                    if (j == 0) {
//                        // First secondary component.
//                        // Separate terciary components.
//                        NSArray *terciaryComponents = [secondaryComponents[0] componentsSeparatedByString:@"_"];
//                        
//                        // Restaurant
//                        
//                    } else {
//                        // Other secondary components.
//                    }
//                }
//            } else {
//                // Other main components.
//            }
//        }
    }];
}

+ (void)requestMenuForWeekWithCompletionHandler:(void (^)(NSArray *weekMenu, NSError *error))handler
{
    // Get week number.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorianCalendar.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    NSDateComponents *dateComponents = [gregorianCalendar components:NSCalendarUnitWeekday|NSCalendarUnitWeekOfYear fromDate:[NSDate date]];
    
    // Generate request string (adjust week to start on monday.
    if (dateComponents.weekday <= 1) {
        dateComponents.weekOfYear--;
    }
    NSString *requestString = [NSString stringWithFormat:@"tag=7$UFJF_%ld", (long)dateComponents.weekOfYear];
    
    // Request with shared session configuration.
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverURLString]];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    [[urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *networkError) {
        // Verify network error.
        if (networkError) {
            // Main thread
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                handler(nil, networkError);
            }];
            return;
        }
        
        // Serialize JSON and get return string.
        NSError *serializationError;
        NSArray *serializationResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&serializationError];
        // Verify serialization error.
        if (serializationError) {
            // Main thread
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                handler(nil, serializationError);
            }];
            return;
        }
        
        // Separete main components if it is a valid menu.
        NSArray *mainComponents = [serializationResult.lastObject componentsSeparatedByString:@"$"];
        if (mainComponents.count <= 1) { // It means there was a server error or that there is no menu.
            // Main thread
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                handler(nil, nil);
            }];
            return;
        }
        NSMutableArray *weekMenu = [NSMutableArray arrayWithCapacity:mainComponents.count];
        for (NSString *mainComponent in mainComponents) {
            [weekMenu addObject:[mainComponent componentsSeparatedByString:@"_"]];
        }
        
        // Main thread
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            handler(weekMenu, nil);
        }];
    }] resume];
}

@end
