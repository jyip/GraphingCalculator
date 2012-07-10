//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Jeffrey Yip on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (void)pushOperation:(NSString *)operation;
- (void)clearOperandStack;
- (void)removeLastObjectFromProgramStack;

@property (nonatomic, readonly) id program;

+ (NSString *)descriptionOfProgram:(id)program;
+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;

@end
