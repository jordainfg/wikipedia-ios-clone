#import "NSMutableAttributedString+WikitextEditingExtensions.h"
#import "Wikipedia-Swift.h"

@implementation NSMutableAttributedString (WikitextEditingExtensions)

-(void)addWikitextSyntaxFormattingWithSearchRange: (NSRange)searchRange fontSizeTraitCollection: (UITraitCollection *)fontSizeTraitCollection needsColors: (BOOL)needsColors {

    UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFontDescriptor *boldFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFontDescriptor *italicFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    UIFontDescriptor *boldItalicFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic | UIFontDescriptorTraitBold];
    UIFont *boldFont = [UIFont fontWithDescriptor:boldFontDescriptor size:0];
    UIFont *italicFont = [UIFont fontWithDescriptor:italicFontDescriptor size:0];
    UIFont *boldItalicFont = [UIFont fontWithDescriptor:boldItalicFontDescriptor size:0];
    
    UIFont *normalFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody compatibleWithTraitCollection:fontSizeTraitCollection];
    UIFont *h2Font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleHeadline] scaledFontForFont:[UIFont systemFontOfSize:36]];
    UIFont *h6Font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleHeadline] scaledFontForFont:[UIFont systemFontOfSize:24]];
    //UIFontMetrics(forTextStyle: style).scaledFont(for: UIFont.systemFont(ofSize: size, weight: weight))

    NSString *boldItalicRegexStr = @"('{5})([^']*(?:'(?!'''')[^']*)*)('{5})";
    NSString *boldRegexStr = @"('{3})([^']*(?:'(?!'')[^']*)*)('{3})";

    // Explaining the most complicated example here, others (bold, italic, link) follow a similar pattern
    // ('{2})       - matches opening ''. Captures in group so it can be orangified.
    // (            - start of capturing group. The group that will be italisized.
    // [^']*        - matches any character that isn't a ' zero or more times
    // (?:          - beginning of non-capturing group
    // (?<!')'(?!') - matches any ' that are NOT followed or preceded by another ' (so single apostrophes or words like "don't" still get formatted
    // [^']*        - matches any character that isn't a ' zero or more times
    // )*           - end of non-capturing group, which can happen zero or more times (i.e. all single apostrophe logic)
    // )            - end of capturing group. End italisization
    // ('{2})       - matches ending ''. Captures in group so it can be orangified.

    NSString *italicRegexStr = @"('{2})([^']*(?:(?<!')'(?!')[^']*)*)('{2})";
    NSString *linkRegexStr = @"(\\[{2})[^\\[]*(?:\\[(?!\\[)[^'\\[]*)*(\\]{2})";
    NSString *templateRegexStr = @"\\{{2}[^\\}]*\\}{2}";
    
    NSString *refRegexStr = @"(<ref>)\\s*.*?(<\\/ref>)";
    NSString *refWithAttributesRegexStr = @"(<ref\\s+.+?>)\\s*.*?(<\\/ref>)";
    NSString *refSelfClosingRegexStr = @"<ref\\s[^>]+?\\s*\\/>";
    NSString *h2RegexStr = @"^(={2})([^=]*)(={2})(?!=)";
    NSString *h6RegexStr = @"^(={6})([^=]*)(={6})(?!=)";
    
    NSString *bulletPointRegexStr = @"^(\\*+)(.*)";
    NSString *listNumberRegexStr = @"^(#+)(.*)";

    NSRegularExpression *boldItalicRegex = [NSRegularExpression regularExpressionWithPattern:boldItalicRegexStr options:0 error:nil];
    NSRegularExpression *boldRegex = [NSRegularExpression regularExpressionWithPattern:boldRegexStr options:0 error:nil];
    NSRegularExpression *italicRegex = [NSRegularExpression regularExpressionWithPattern:italicRegexStr options:0 error:nil];
    NSRegularExpression *linkRegex = [NSRegularExpression regularExpressionWithPattern:linkRegexStr options:0 error:nil];
    NSRegularExpression *templateRegex = [NSRegularExpression regularExpressionWithPattern:templateRegexStr options:0 error:nil];
    NSRegularExpression *refRegex = [NSRegularExpression regularExpressionWithPattern:refRegexStr options:0 error:nil];
    NSRegularExpression *refWithAttributesRegex = [NSRegularExpression regularExpressionWithPattern:refWithAttributesRegexStr options:0 error:nil];
    NSRegularExpression *refSelfClosingRegex = [NSRegularExpression regularExpressionWithPattern:refSelfClosingRegexStr options:0 error:nil];
    NSRegularExpression *h2Regex = [NSRegularExpression regularExpressionWithPattern:h2RegexStr options:0 error:nil];
    NSRegularExpression *h6Regex = [NSRegularExpression regularExpressionWithPattern:h6RegexStr options:0 error:nil];
    NSRegularExpression *bulletPointRegex = [NSRegularExpression regularExpressionWithPattern:bulletPointRegexStr options:0 error:nil];
    NSRegularExpression *listNumberRegex = [NSRegularExpression regularExpressionWithPattern:listNumberRegexStr options:0 error:nil];

    NSDictionary *boldAttributes = @{
        NSFontAttributeName: boldFont,
    };

    NSDictionary *italicAttributes = @{
        NSFontAttributeName: italicFont,
    };

    NSDictionary *boldItalicAttributes = @{
        NSFontAttributeName: boldItalicFont,
    };

    NSDictionary *linkAttributes = @{
        NSForegroundColorAttributeName: [UIColor systemBlueColor]
    };
    
    NSDictionary *templateAttributes = @{
        NSForegroundColorAttributeName: [UIColor systemPurpleColor]
    };
    
    NSDictionary *refAttributes = @{
        NSForegroundColorAttributeName: [UIColor systemTealColor]
    };

    NSDictionary *orangeFontAttributes = @{
        NSForegroundColorAttributeName: [UIColor systemOrangeColor]
    };
    
    NSDictionary *h2FontAttributes = @{
        NSFontAttributeName: h2Font,
    };
    
    NSDictionary *h6FontAttributes = @{
        NSFontAttributeName: h6Font,
    };

    NSDictionary *normalAttributes = @{
        NSFontAttributeName: normalFont,
        NSForegroundColorAttributeName: [UIColor blackColor]
    };
    
    NSDictionary *wikitextBoldAttributes = @{
        [WMFWikitextAttributedStringKeyWrapper boldKey]: [NSNumber numberWithBool:YES]
    };
    
    NSDictionary *wikitextItalicAttributes = @{
        [WMFWikitextAttributedStringKeyWrapper italicKey]: [NSNumber numberWithBool:YES]
    };
    
    NSDictionary *wikitextBoldAndItalicAttributes = @{
        [WMFWikitextAttributedStringKeyWrapper boldAndItalicKey]: [NSNumber numberWithBool:YES]
    };
    
    NSDictionary *wikitextLinkAttributes = @{
        [WMFWikitextAttributedStringKeyWrapper linkKey]: [NSNumber numberWithBool:YES]
    };
    
    NSDictionary *wikitextTemplateAttributes = @{
        [WMFWikitextAttributedStringKeyWrapper templateKey]: [NSNumber numberWithBool:YES]
    };
    
    NSDictionary *wikitextRefAttributes = @{
        [WMFWikitextAttributedStringKeyWrapper refKey]: [NSNumber numberWithBool:YES]
    };
    
    NSDictionary *wikitextRefWithAttributesAttributes = @{
        [WMFWikitextAttributedStringKeyWrapper refWithAttributesKey]: [NSNumber numberWithBool:YES]
    };
    
    NSDictionary *wikitextRefSelfClosingAttributes = @{
        [WMFWikitextAttributedStringKeyWrapper refSelfClosingKey]: [NSNumber numberWithBool:YES]
    };
    
    NSDictionary *wikitextH2Attributes = @{
        [WMFWikitextAttributedStringKeyWrapper h2Key]: [NSNumber numberWithBool:YES]
    };
    
    NSDictionary *wikitextH6Attributes = @{
        [WMFWikitextAttributedStringKeyWrapper h6Key]: [NSNumber numberWithBool:YES]
    };
    
    NSDictionary *wikitextBulletAttributes = @{
        [WMFWikitextAttributedStringKeyWrapper bulletKey]: [NSNumber numberWithBool:YES]
    };
    
    NSDictionary *wikitextListNumberAttributes = @{
        [WMFWikitextAttributedStringKeyWrapper listNumberKey]: [NSNumber numberWithBool:YES]
    };
    
    [self addAttributes:normalAttributes range:searchRange];
    
    [refRegex enumerateMatchesInString:self.string
                                  options:0
                                    range:searchRange
                               usingBlock:^(NSTextCheckingResult *_Nullable result, NSMatchingFlags flags, BOOL *_Nonnull stop) {
                                  NSRange matchRange = [result rangeAtIndex:0];
                                  NSRange openingRange = [result rangeAtIndex:1];
                                  NSRange closingRange = [result rangeAtIndex:2];

                                    if (matchRange.location != NSNotFound) {
                                        [self addAttributes:wikitextRefAttributes range:matchRange];
                                    }
        
                                   if (openingRange.location != NSNotFound) {
                                       [self addAttributes:refAttributes range:openingRange];
                                   }
        
                                    if (closingRange.location != NSNotFound) {
                                        [self addAttributes:refAttributes range:closingRange];
                                    }
                                    
                               }];
    
    [refWithAttributesRegex enumerateMatchesInString:self.string
                                  options:0
                                    range:searchRange
                               usingBlock:^(NSTextCheckingResult *_Nullable result, NSMatchingFlags flags, BOOL *_Nonnull stop) {
                                  NSRange matchRange = [result rangeAtIndex:0];

                                    if (matchRange.location != NSNotFound) {
                                        [self addAttributes:refAttributes range:matchRange];
                                        [self addAttributes:wikitextRefWithAttributesAttributes range:matchRange];
                                    }
                               }];
    
    [refSelfClosingRegex enumerateMatchesInString:self.string
                                  options:0
                                    range:searchRange
                               usingBlock:^(NSTextCheckingResult *_Nullable result, NSMatchingFlags flags, BOOL *_Nonnull stop) {
                                  NSRange matchRange = [result rangeAtIndex:0];

                                    if (matchRange.location != NSNotFound) {
                                        [self addAttributes:refAttributes range:matchRange];
                                        [self addAttributes:wikitextRefSelfClosingAttributes range:matchRange];
                                    }
                               }];
    
    [templateRegex enumerateMatchesInString:self.string
                                  options:0
                                    range:searchRange
                               usingBlock:^(NSTextCheckingResult *_Nullable result, NSMatchingFlags flags, BOOL *_Nonnull stop) {
                                  NSRange matchRange = [result rangeAtIndex:0];

                                   if (matchRange.location != NSNotFound) {
                                       [self addAttributes:templateAttributes range:matchRange];
                                       [self addAttributes:wikitextTemplateAttributes range:matchRange];
                                   }
                                    
                               }];

    [italicRegex enumerateMatchesInString:self.string
                                  options:0
                                    range:searchRange
                               usingBlock:^(NSTextCheckingResult *_Nullable result, NSMatchingFlags flags, BOOL *_Nonnull stop) {
                                   NSRange openingRange = [result rangeAtIndex:1];
                                   NSRange textRange = [result rangeAtIndex:2];
                                   NSRange closingRange = [result rangeAtIndex:3];

                                   if (textRange.location != NSNotFound) {
                                       [self addAttributes:italicAttributes range:textRange];
                                       [self addAttributes:wikitextItalicAttributes range:textRange];
                                   }

                                   if (openingRange.location != NSNotFound) {
                                       [self addAttributes:orangeFontAttributes range:openingRange];
                                   }

                                   if (closingRange.location != NSNotFound) {
                                       [self addAttributes:orangeFontAttributes range:closingRange];
                                   }
                                    
                               }];

    [boldRegex enumerateMatchesInString:self.string
                                options:0
                                  range:searchRange
                             usingBlock:^(NSTextCheckingResult *_Nullable result, NSMatchingFlags flags, BOOL *_Nonnull stop) {
                                NSRange fullMatch = [result rangeAtIndex:0];
                                 NSRange openingRange = [result rangeAtIndex:1];
                                 NSRange textRange = [result rangeAtIndex:2];
                                 NSRange closingRange = [result rangeAtIndex:3];

                                 if (textRange.location != NSNotFound) {
                                     
                                     // helps to undo attributes from bold and italic single regex above.
                                    [self removeAttribute:[WMFWikitextAttributedStringKeyWrapper italicKey] range:fullMatch];
                                     
                                     [self addAttributes:boldAttributes range:textRange];
                                     [self addAttributes:wikitextBoldAttributes range:textRange];
                                 }

                                 if (openingRange.location != NSNotFound) {
                                     [self addAttributes:orangeFontAttributes range:openingRange];
                                 }

                                 if (closingRange.location != NSNotFound) {
                                     [self addAttributes:orangeFontAttributes range:closingRange];
                                 }
                             }];

    [boldItalicRegex enumerateMatchesInString:self.string
                                      options:0
                                        range:searchRange
                                   usingBlock:^(NSTextCheckingResult *_Nullable result, NSMatchingFlags flags, BOOL *_Nonnull stop) {
                                       NSRange fullMatch = [result rangeAtIndex:0];
                                       NSRange openingRange = [result rangeAtIndex:1];
                                       NSRange textRange = [result rangeAtIndex:2];
                                       NSRange closingRange = [result rangeAtIndex:3];

                                       if (textRange.location != NSNotFound) {
                                           
                                           // helps to undo attributes from bold and italic single regex above.
                                           [self removeAttribute:NSFontAttributeName range:fullMatch];
                                           [self removeAttribute:NSForegroundColorAttributeName range:fullMatch];
                                           [self removeAttribute:[WMFWikitextAttributedStringKeyWrapper boldKey] range:fullMatch];
                                           [self removeAttribute:[WMFWikitextAttributedStringKeyWrapper italicKey] range:fullMatch];
                                           [self addAttributes:normalAttributes range:fullMatch];
                                           
                                           [self addAttributes:boldItalicAttributes range:textRange];
                                           [self addAttributes:wikitextBoldAndItalicAttributes range:textRange];
                                       }

                                       if (openingRange.location != NSNotFound) {
                                           [self addAttributes:orangeFontAttributes range:openingRange];
                                       }

                                       if (closingRange.location != NSNotFound) {
                                           [self addAttributes:orangeFontAttributes range:closingRange];
                                       }
                                   }];

    [linkRegex enumerateMatchesInString:self.string
                                options:0
                                  range:searchRange
                             usingBlock:^(NSTextCheckingResult *_Nullable result, NSMatchingFlags flags, BOOL *_Nonnull stop) {
                                 NSRange matchRange = [result rangeAtIndex:0];

                                 if (matchRange.location != NSNotFound) {
                                     [self addAttributes:linkAttributes range:matchRange];
                                     [self addAttributes:wikitextLinkAttributes range:matchRange];
                                 }
                             }];
    
    [h2Regex enumerateMatchesInString:self.string
                                  options:0
                                    range:searchRange
                               usingBlock:^(NSTextCheckingResult *_Nullable result, NSMatchingFlags flags, BOOL *_Nonnull stop) {
                                   NSRange openingRange = [result rangeAtIndex:1];
                                   NSRange textRange = [result rangeAtIndex:2];
                                   NSRange closingRange = [result rangeAtIndex:3];

                                   if (textRange.location != NSNotFound) {
                                       [self addAttributes:h2FontAttributes range:textRange];
                                       [self addAttributes:wikitextH2Attributes range:textRange];
                                   }

                                   if (openingRange.location != NSNotFound) {
                                       [self addAttributes:orangeFontAttributes range:openingRange];
                                       [self addAttributes:h2FontAttributes range:openingRange];
                                   }

                                   if (closingRange.location != NSNotFound) {
                                       [self addAttributes:orangeFontAttributes range:closingRange];
                                       [self addAttributes:h2FontAttributes range:closingRange];
                                   }
                               }];
    
    [h6Regex enumerateMatchesInString:self.string
                                  options:0
                                    range:searchRange
                               usingBlock:^(NSTextCheckingResult *_Nullable result, NSMatchingFlags flags, BOOL *_Nonnull stop) {
                                   NSRange openingRange = [result rangeAtIndex:1];
                                   NSRange textRange = [result rangeAtIndex:2];
                                   NSRange closingRange = [result rangeAtIndex:3];

                                   if (textRange.location != NSNotFound) {
                                       [self addAttributes:h6FontAttributes range:textRange];
                                       [self addAttributes:wikitextH6Attributes range:textRange];
                                   }

                                   if (openingRange.location != NSNotFound) {
                                       [self addAttributes:orangeFontAttributes range:openingRange];
                                       [self addAttributes:h6FontAttributes range:openingRange];
                                   }

                                   if (closingRange.location != NSNotFound) {
                                       [self addAttributes:orangeFontAttributes range:closingRange];
                                       [self addAttributes:h6FontAttributes range:closingRange];
                                   }
                               }];
    
    [bulletPointRegex enumerateMatchesInString:self.string
                                  options:0
                                    range:searchRange
                               usingBlock:^(NSTextCheckingResult *_Nullable result, NSMatchingFlags flags, BOOL *_Nonnull stop) {
                                NSRange allRange = [result rangeAtIndex:0];
                                   NSRange bulletRange = [result rangeAtIndex:1];

                                   if (bulletRange.location != NSNotFound) {
                                       [self addAttributes:orangeFontAttributes range:bulletRange];
                                   }
        
                                    if (allRange.location != NSNotFound) {
                                        [self addAttributes:wikitextBulletAttributes range:allRange];
                                    }
                               }];
}

@end
