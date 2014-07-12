
#import "SyntaxDefinitionManager.h"
#import "../IconManager/IconManager.h"
#import "../ProjectLoad/ProjLoadTools.h"

@interface SyntaxDefinitionManager()
+ (NSString*)getSyntaxDefinitionFilePath:(NSString*)fileName;
@end


@implementation SyntaxDefinitionManager

static NSMutableArray* syntaxDefinitionNames = [[NSMutableArray alloc] init];
static NSMutableArray* syntaxDefinitions = [[NSMutableArray alloc] init];



#define extensions_header (const char*[]){"h"}
#define total_header 1

#define extensions_objectivec (const char*[]){"m", "mm"}
#define total_objectivec 2

#define extensions_cpp (const char*[]){"cpp", "cc", "c++", "cp", "cxx"}
#define total_cpp 1

#define extensions_c (const char*[]){"c"}
#define total_c 2

#define extensions_batch (const char*[]){"bat", "cmd"}
#define total_batch 2

#define extensions_html (const char*[]){"htm", "html"}
#define total_html 2

#define extensions_css (const char*[]){"css"}
#define total_css 1

#define extensions_java (const char*[]){"java"}
#define total_java 1

#define extensions_javascript (const char*[]){"js"}
#define total_javascript 1

#define extensions_lua (const char*[]){"lua"}
#define total_lua 1

#define extensions_perl (const char*[]){"pl", "pm", "cgi"}
#define total_perl 3

#define extensions_python (const char*[]){"py"}
#define total_python 1

#define extensions_ruby (const char*[]){"rb", "rbw"}
#define total_ruby 2

#define extensions_shell (const char*[]){"sh", "bash", "zsh"}
#define total_shell 3



bool ArrayContainsString(const char** array, int size, const char* str)
{
	int strLength = strlen(str);
	for(int i=0; i<size; i++)
	{
		const char* tmpStr = array[i];
		int tmpStrLength = strlen(str);
		if(strLength==tmpStrLength)
		{
			bool match = true;
			for(int j=0; j<strLength; j++)
			{
				if(str[j]!=tmpStr[j])
				{
					j = strLength;
					match = false;
				}
			}
			
			if(match)
			{
				return true;
			}
		}
	}
	return false;
}

+ (NSString*)getSyntaxDefinitionFilePath:(NSString*)fileName
{
	NSString* extensionStr = [IconManager getExtensionForFilename:fileName];
	const char* extension = [extensionStr UTF8String];
	
	if(ArrayContainsString(extensions_header, total_header, extension))
	{
		return @"header.plist";
	}
	else if(ArrayContainsString(extensions_objectivec, total_objectivec, extension))
	{
		return @"objectivec.plist";
	}
	else if(ArrayContainsString(extensions_cpp, total_cpp, extension))
	{
		return @"cpp.plist";
	}
	else if(ArrayContainsString(extensions_c, total_c, extension))
	{
		return @"c.plist";
	}
	else if(ArrayContainsString(extensions_batch, total_batch, extension))
	{
		return @"batch.plist";
	}
	else if(ArrayContainsString(extensions_html, total_html, extension))
	{
		return @"html.plist";
	}
	else if(ArrayContainsString(extensions_css, total_css, extension))
	{
		return @"css.plist";
	}
	else if(ArrayContainsString(extensions_java, total_java, extension))
	{
		return @"java.plist";
	}
	else if(ArrayContainsString(extensions_javascript, total_javascript, extension))
	{
		return @"javascript.plist";
	}
	else if(ArrayContainsString(extensions_lua, total_lua, extension))
	{
		return @"lua.plist";
	}
	else if(ArrayContainsString(extensions_perl, total_perl, extension))
	{
		return @"perl.plist";
	}
	else if(ArrayContainsString(extensions_python, total_python, extension))
	{
		return @"python.plist";
	}
	else if(ArrayContainsString(extensions_ruby, total_ruby, extension))
	{
		return @"ruby.plist";
	}
	else if(ArrayContainsString(extensions_shell, total_shell, extension))
	{
		return @"shell.plist";
	}
	
	return @"none.plist";
}

+ (NSDictionary*)loadSyntaxDefinitionsForFile:(NSString*)fileName
{
	NSString* syntaxDefinitionPlist = [SyntaxDefinitionManager getSyntaxDefinitionFilePath:fileName];
	for(unsigned int i=0; i<[syntaxDefinitionNames count]; i++)
	{
		if([syntaxDefinitionPlist isEqual:[syntaxDefinitionNames objectAtIndex:i]])
		{
			return [syntaxDefinitions objectAtIndex:i];
		}
	}
	
	NSMutableString* fullPath = [[NSMutableString alloc] initWithUTF8String:"Syntax Definitions/"];
	[fullPath appendString:syntaxDefinitionPlist];
	
	NSDictionary* plist = (NSDictionary*)ProjLoad_loadAllocatedPlist([fullPath UTF8String]);
	[fullPath release];
	
	[syntaxDefinitions addObject:plist];
	[plist release];
	[syntaxDefinitionNames addObject:syntaxDefinitionPlist];
	
	return plist;
}

@end
