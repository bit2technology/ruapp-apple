//
//  RUAServerConnection.m
//  RUapp
//
//  Created by Igor Camilo on 18/06/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAServerConnection.h"
#import "RUAAppDelegate.h"

@implementation RUAServerConnection

+ (void)sendVoteWithRestaurant:(RUARestaurant)restaurant vote:(RUARating)vote reason:(RUADish *)reason completionHandler:(void (^)(void))handler
{
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
    
    // Background thread
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        // Components of vote server request.
        NSMutableArray *stringComponents = [NSMutableArray arrayWithCapacity:6];
        
        // Restaurant
        [stringComponents addObject:[NSString stringWithFormat:@"UFJF%lu", (unsigned long)restaurant + 1]];
        
        // Date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy";
        NSDate *now = [NSDate date];
        [stringComponents addObject:[dateFormatter stringFromDate:now]];
        
        // Meal
        [stringComponents addObject:[NSString stringWithFormat:@"%lu", (unsigned long)[RUAAppDelegate mealForDate:now] + 1]];
        
        // Vote
        [stringComponents addObject:[NSString stringWithFormat:@"%lu", (unsigned long)vote + 1]];
        
        // Reason
        if (reason[0] == RUADishNone) {
            [stringComponents addObject:@"00"];
        } else {
            NSMutableArray *reasonComponents = [NSMutableArray arrayWithCapacity:RUADishTotal];
            for (NSUInteger i = 0; i < RUADishTotal; i++) {
                if (reason[i] == RUADishNone) break;
                [reasonComponents addObject:[NSString stringWithFormat:@"%02lu", (unsigned long)reason[i] + 1]];
            }
            [stringComponents addObject:[reasonComponents componentsJoinedByString:@"."]];
        }
        
        // Device ID
        [stringComponents addObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
        
        // Request
        NSString *requestString = [stringComponents componentsJoinedByString:@"_"]; //[NSString stringWithFormat:@"%@_%@_%@_%@_%@_%@", serverRestaurant, serverDate, serverMeal, serverVote, serverReason, serverDeviceId];
        NSLog(@"sendVote: %@", requestString); // TODO: Actual request.
        
        // Main thread
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Run completion handler.
            handler();
        }];
    }];
}

+ (void)requestResultsWithDate:(NSDate *)date completionHandler:(void (^)(void))handler
{
    /*
     Resultado de votação:
     UFJF2_03.05.2014_2$8$7$3$5#3$0$2$2$0$1$0#3$2$0$0$0$0$0#0$0$0$1$1$0$1#0$0$2$2$1$0$1
     
     Algoritmo:
      Separar a string nas “#”, formando uma lista.
     
     Item 0 da lista: (UFJF2_03.05.2014_2$8$7$3$5)
     o o o o o
     
     Separar string nos “$”, formando outra lista Item 0 da lista = votos muito bom
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
    
    // Background thread
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        NSString *resultsString = @"UFJF2_03.05.2014_2$8$7$3$5#3$0$2$2$0$1$0#3$2$0$0$0$0$0#0$0$0$1$1$0$1#0$0$2$2$1$0$1";
        
        NSArray *mainComponents = [resultsString componentsSeparatedByString:@"#"];
        for (NSUInteger i = 0; i < mainComponents.count; i++) {
            
            if (i == 0) {
                
            } else {
                
            }
        }
    }];
}

+ (void)requestMenuForWeekWithCompletionHandler:(void (^)(NSArray *weekMenu))handler
{
    /*Cardápio:
     pratoPrincipal1_opção1_guarnição1_massa1_acompanhamento1_saladas1_sobremesa1$ pratoprincipal2_opção2_guarnição2_massa2_acompanhamento2_saladas2_sobremesa2$ ....... Pratoprincipal14_opção14_guarnição14_massa14_acompanhamento14_saladas14_sobremes a14
     Algoritmo:
      Separar a string nas “$”, formando uma lista.
      Cada item da lista é um cardápio da semana. Os índices são:
     o Item 0: almoço de segunda feira o Item 1: jantar de segunda-feira o Item 2: almoço de terça feira
     o ...
     o Até Item 14: jantar de domingo
      Separar cada um dos itens da lista nos “_”
     o Cada um deles está explicado no próprio modelo acima.*/
    
    // Background thread
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        NSString *requestString = @"pratoPrincipal1_opção1_guarnição1_massa1_acompanhamento1_saladas1_sobremesa1$pratoPrincipal2_opção2_guarnição2_massa2_acompanhamento2_saladas2_sobremesa2$pratoPrincipal3_opção3_guarnição3_massa3_acompanhamento3_saladas3_sobremesa3$pratoPrincipal4_opção4_guarnição4_massa4_acompanhamento4_saladas4_sobremesa4$pratoPrincipal5_opção5_guarnição5_massa5_acompanhamento5_saladas5_sobremesa5$pratoPrincipal6_opção6_guarnição6_massa6_acompanhamento6_saladas6_sobremesa6$pratoPrincipal7_opção7_guarnição7_massa7_acompanhamento7_saladas7_sobremesa7$pratoPrincipal8_opção8_guarnição8_massa8_acompanhamento8_saladas8_sobremesa8$pratoPrincipal9_opção9_guarnição9_massa9_acompanhamento9_saladas9_sobremesa9$pratoPrincipal10_opção10_guarnição10_massa10_acompanhamento10_saladas10_sobremesa10$pratoPrincipal11_opção11_guarnição11_massa11_acompanhamento11_saladas11_sobremesa11$pratoPrincipal12_opção12_guarnição12_massa12_acompanhamento12_saladas12_sobremesa12$pratoPrincipal13_opção13_guarnição13_massa13_acompanhamento13_saladas13_sobremesa13$pratoPrincipal14_opção14_guarnição14_massa14_acompanhamento14_saladas14_sobremesa14";
        
        NSArray *mainComponents = [requestString componentsSeparatedByString:@"$"];
        NSMutableArray *weekMenu = [NSMutableArray arrayWithCapacity:mainComponents.count];
        for (NSString *mainComponent in mainComponents) {
            [weekMenu addObject:[mainComponent componentsSeparatedByString:@"_"]];
        }
        
        // Main thread
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Run completion handler.
            handler(weekMenu);
        }];
    }];
}

@end
