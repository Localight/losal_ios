//
//  LAPostItem.m
//  #LOSAL
//
//  Created by James Orion Hall on 7/31/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAPostItem.h"

@implementation LAPostItem

@synthesize publicationDate;

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_firstName forKey:@"firstName"];
    [aCoder encodeObject:_lastName forKey:@"lastName"];
    [aCoder encodeObject:_academicLevel forKey:@"academicLevel"];
    
    [aCoder encodeObject:publicationDate forKey:@"publicationDate"];
    [aCoder encodeObject:_imageKey forKey:@"imageKey"];
    [aCoder encodeObject:_postImage forKey:@"postImage"];
    [aCoder encodeObject:_imagePostData forKey:@"imagePostData"];
    [aCoder encodeObject:_messageContent forKey:@"messageContent"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self) {
       // [self setTitle:[aDecoder decodeObjectForKey:@"title"]];
        [self setFirstName:[aDecoder decodeObjectForKey:@"firstName"]];
        [self setLastName:[aDecoder decodeObjectForKey:@"lastName"]];
        [self setAcademicLevel:[aDecoder decodeObjectForKey:@"AcademicLevel"]];
        //[self publicationDate
        
    }
    return self;
}


@end
