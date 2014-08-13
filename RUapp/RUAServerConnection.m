//
//  RUAServerConnection.m
//  RUapp
//
//  Created by Igor Camilo on 18/06/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAServerConnection.h"
#import "RUAAppDelegate.h"

@interface RUAResultInfo ()

@property (assign, nonatomic) RUARestaurant restaurant;
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) RUAMeal meal;
@property (strong, nonatomic) NSArray *votes;

@end

@implementation RUAResultInfo

//- (NSInteger)votes
//{
//    return self.votesBad + self.votesGood + self.votesVeryBad + self.votesVeryGood;
//}

@end

@implementation RUAServerConnection

/*
 Envio de voto:
 UFJF2_02.05.2014_2_1_01.03_a
 
 Estrutura:
 Unidade_data_refeição_voto_justificativa_idDoAparelho
 
 Códigos:
 - Unidade:
 UFJF1 = centro;
 UFJF2 = Campus
 - Data:
 Dia.mes.ano
 - Voto:
 1 = muito bom
 2 = bom
 3 = ruim
 4 = muito ruim
 - Justificativa:
 Conjunto de números de 01 a 07
 - Montar: “justificativa1.justificativa2.justificativaN”
 Sendo o número de cada justificativa:
 01. Prato principal
 02. Opção vegetariana
 03. Guarnição
 04. Massa
 05. Acompanhamento
 06. Salada
 07. Sobremesa
 - idDoAparelho
 Identificação única.
 */

+ (void)sendVoteWithRestaurant:(RUARestaurant)restaurant vote:(RUARating)vote reason:(NSArray *)reason completionHandler:(void (^)(NSDate *voteDate, NSError *error))handler
{
    // Background thread
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        // Components of vote server request.
        NSMutableArray *stringComponents = [NSMutableArray arrayWithCapacity:6];
        
        // Restaurant
        [stringComponents addObject:[NSString stringWithFormat:@"UFJF%lu", (unsigned long)restaurant + 1]];
        
        // Date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy";
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
        [stringComponents addObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
        
        // Request
        NSString *requestString = [stringComponents componentsJoinedByString:@"_"];
        // TODO: Actual request.
        
        NSLog(@"sendVote: %@", requestString);
        
        // Main thread
        //[[NSOperationQueue mainQueue] addOperationWithBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            handler(now, [[NSError alloc] init]);
        });
    }];
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

/*
 Cardápio: pratoPrincipal1_opção1_guarnição1_massa1_acompanhamento1_saladas1_sobremesa1$pratoprincipal2_opção2_guarnição2_massa2_acompanhamento2_saladas2_sobremesa2$...$Pratoprincipal14_opção14_guarnição14_massa14_acompanhamento14_saladas14_sobremesa14
 Algoritmo:
 - Separar a string nas “$”, formando uma lista.
 - Cada item da lista é um cardápio da semana. Os índices são:
   - Item 0: almoço de segunda feira
   - Item 1: jantar de segunda-feira
   - Item 2: almoço de terça feira
   ...
   - Até Item 14: jantar de domingo
 - Separar cada um dos itens da lista nos “_”
 - Cada um deles está explicado no próprio modelo acima.
 */

+ (void)requestMenuForWeekWithCompletionHandler:(void (^)(NSArray *weekMenu, NSError *error))handler
{
    // Background thread
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        // Download result string.
        NSString *requestString = @"pratoPrincipal1_opção1_guarnição1_massa1_acompanhamento1_saladas1_sobremesa1$pratoPrincipal2_opção2_guarnição2_massa2_acompanhamento2_saladas2_sobremesa2$pratoPrincipal3_opção3_guarnição3_massa3_acompanhamento3_saladas3_sobremesa3$pratoPrincipal4_opção4_guarnição4_massa4_acompanhamento4_saladas4_sobremesa4$pratoPrincipal5_opção5_guarnição5_massa5_acompanhamento5_saladas5_sobremesa5$pratoPrincipal6_opção6_guarnição6_massa6_acompanhamento6_saladas6_sobremesa6$pratoPrincipal7_opção7_guarnição7_massa7_acompanhamento7_saladas7_sobremesa7$pratoPrincipal8_opção8_guarnição8_massa8_acompanhamento8_saladas8_sobremesa8$pratoPrincipal9_opção9_guarnição9_massa9_acompanhamento9_saladas9_sobremesa9$pratoPrincipal10_opção10_guarnição10_massa10_acompanhamento10_saladas10_sobremesa10$pratoPrincipal11_opção11_guarnição11_massa11_acompanhamento11_saladas11_sobremesa11$pratoPrincipal12_opção12_guarnição12_massa12_acompanhamento12_saladas12_sobremesa12$pratoPrincipal13_opção13_guarnição13_massa13_acompanhamento13_saladas13_sobremesa13$pratoPrincipal14_opção14_guarnição14_massa14_acompanhamento14_saladas14_sobremesa14";
        
        // Separete main components.
        NSArray *mainComponents = [requestString componentsSeparatedByString:@"$"];
        NSMutableArray *weekMenu = [NSMutableArray arrayWithCapacity:mainComponents.count];
        for (NSString *mainComponent in mainComponents) {
            [weekMenu addObject:[mainComponent componentsSeparatedByString:@"_"]];
        }
        
        // Main thread
        //[[NSOperationQueue mainQueue] addOperationWithBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            // Run completion handler.
            handler(weekMenu, nil);
        });
    }];
}

@end
