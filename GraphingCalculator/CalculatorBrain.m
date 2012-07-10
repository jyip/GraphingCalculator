//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Jeffrey Yip on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@property (nonatomic, strong) NSDictionary *variableValues;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;
@synthesize variableValues = _variableValues;

- (NSMutableArray *)programStack
{
    if (_programStack == nil) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (NSDictionary *)variableValues
{
    if(_variableValues == nil) {
        _variableValues = [[NSDictionary alloc] init];
    }
    return _variableValues;
}

- (id)program
{
    return [self.programStack copy];
}

- (void)pushOperand:(double)operand
{   
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void)pushOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
}

+ (BOOL)isTwoOperandOperation:(NSString *)operation
{
    NSSet *twoOperandOperations = [NSSet setWithObjects:@"+",@"-",@"*",@"/", nil];
    return [twoOperandOperations containsObject:operation];
}

+ (BOOL)isOneOperandOperation:(NSString *)operation
{
    NSSet *oneOperandOperations = [NSSet setWithObjects:@"sin",@"cos",@"sqrt", nil];
    return [oneOperandOperations containsObject:operation];
}

/*
 + (BOOL)isNoOperandOperation:(NSString *)operation
 {
 NSSet *noOperandOperations = [NSSet setWithObjects:@"π", nil];
 return [noOperandOperations containsObject:operation];
 }
*/

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
{
    NSString *description = @"";
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if([topOfStack isKindOfClass:[NSNumber class]])
    {
        description = [topOfStack stringValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        NSString *stringFormat = @"";
        if ([self isTwoOperandOperation:operation]) {
            NSInteger stackCount = [stack count];
            NSString *secondOperand = [self descriptionOfTopOfStack:stack];
            NSString *firstOperand = [self descriptionOfTopOfStack:stack]; 
            if([secondOperand rangeOfString:@"("].location == NSNotFound && stackCount >= 2) {
                stringFormat = @"(%@ %@ %@)";
            } else {
                stringFormat = @"%@ %@ %@";
            }
            
            description = [description stringByAppendingFormat:stringFormat, firstOperand, operation, secondOperand];
            
        }
        else if ([self isOneOperandOperation:operation]) {
            description = [description stringByAppendingFormat:@"%@(%@)", operation, 
                           [self descriptionOfTopOfStack:stack]];
        }
        else {
            description = [description stringByAppendingFormat:@" %@ ",operation];
        }
    }
    
    //NSLog(@"%@",description);
    //NSLog(@"stack count: %d", [stack count]);
    return description;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    NSString *programDescription = [self descriptionOfTopOfStack:stack];
    
    while ([stack count] > 0) {
        programDescription = [programDescription stringByAppendingFormat:@", %@", [self descriptionOfTopOfStack:stack]];
    }
    
    // remove extra parentheses from beginning and end of programDescription
    if([programDescription hasPrefix:@"("] && [programDescription hasSuffix:@")"] 
       && [programDescription rangeOfString:@") "].location == NSNotFound 
       && [programDescription rangeOfString:@" ("].location == NSNotFound) {
            programDescription = [programDescription substringFromIndex:1];
            programDescription = [programDescription substringToIndex:[programDescription length]-1];
    }
    
    //NSLog(@"return programDescription");
    return programDescription;
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    NSSet *variableKeys = [NSSet setWithObjects:@"x", @"y", @"foo", nil];
    NSMutableSet *variableKeysInProgram = [[NSMutableSet alloc] init];
    
    for (id key in variableKeys) {
        if ([stack containsObject:key]) {
            [variableKeysInProgram addObject:key];
        }
    }
    
    if([variableKeysInProgram count] > 0) {
        return [variableKeysInProgram copy];
    } else {
        return nil;
    }
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack] + [self popOperandOffProgramStack:stack];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffProgramStack:stack] * [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            if(divisor) result = [self popOperandOffProgramStack:stack] / divisor;
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"sqrt"]) {
            result = sqrt([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        } else {
            result = 0;
        }
    }
    
    return result;
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    // replace variable values with dictionary objects
    for (NSInteger i = 0; i < [stack count]; i++) {
        if([variableValues objectForKey:[stack objectAtIndex:i]]) {
            id dictObject = [variableValues objectForKey:[stack objectAtIndex:i]];
            [stack replaceObjectAtIndex:i withObject:dictObject];
        }
    }
    
    return [self popOperandOffProgramStack:stack];
}

- (void)clearOperandStack
{
    self.programStack = nil;
}

- (void)removeLastObjectFromProgramStack
{
    [self.programStack removeLastObject];
}

@end
