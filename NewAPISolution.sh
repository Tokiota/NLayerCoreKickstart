SolutionName=$1;
SolutionFile="$SolutionName/$SolutionName.sln";
gitIgnorePath="$SolutionName/.gitignore";
projExt=".csproj";

#webApi
WebApiName="$SolutionName.Api";
WebApiTestName="$SolutionName.Api.UnitTest"
WebApiPath=${SolutionName%%/}/src/$WebApiName;
WebApiProj=${WebApiPath%%/}/$WebApiName$projExt;
WebApiTestPath=${SolutionName%%/}/test/$WebApiTestName;
WebApiTestProj=${WebApiTestPath%%/}/$WebApiTestName$projExt;

#WebApiMessages
WebApiMessagesName="$SolutionName.Api.Messages";
WebApiMessagesPath=${SolutionName%%/}/src/$WebApiMessagesName;
WebApiMessagesProj=${WebApiMessagesPath%%/}/$WebApiMessagesName$projExt;

#app UseCases
AppLayerName="$SolutionName.UseCases";
AppLayerTestName="$SolutionName.UseCases.Tests"
AppLayerPath=${SolutionName%%/}/src/$AppLayerName;
AppLayerProj=${AppLayerPath%%/}/$AppLayerName$projExt;
AppLayerTestPath=${SolutionName%%/}/test/$AppLayerTestName;
AppLayerTestProj=${AppLayerTestPath%%/}/$AppLayerTestName$projExt;

#BL layer
BLayerName="$SolutionName.Business";
BLayerTestName="$SolutionName.Business.UnitTests"
BLayerPath=${SolutionName%%/}/src/$BLayerName;
BLayerProj=${BLayerPath%%/}/$BLayerName$projExt;
BLayerTestPath=${SolutionName%%/}/test/$BLayerTestName;
BLayerTestProj=${BLayerTestPath%%/}/$BLayerTestName$projExt;

#Data Access layer
DALayerName="$SolutionName.DataAccess";
DALayerPath=${SolutionName%%/}/src/$DALayerName;
DALayerProj=${DALayerPath%%/}/$DALayerName$projExt;

#Entities
EntitiesName="$SolutionName.DataAccess.Entities";
EntitiesPath=${SolutionName%%/}/src/$EntitiesName;
EntitiesProj=${EntitiesPath%%/}/$EntitiesName$projExt;

echo -e "\033[1;92m Creating solution \033[0m"
dotnet new sln -n $SolutionName -o "$SolutionName"

echo -e "\033[1;92m Creating Api Message Dtos Project \033[0m"
dotnet new classlib -n $WebApiMessagesName -o "$WebApiMessagesPath" -f netcoreapp2.0

echo -e "\033[1;92m Creating REST Api Layer \033[0m"
dotnet new webapi -n $WebApiName -o "$WebApiPath" -f netcoreapp2.0

echo -e "\033[1;92m Creating Api unit tests project \033[0m"
dotnet new xunit -n $WebApiTestName -o "$WebApiTestPath" -f netcoreapp2.0

echo -e "\033[1;92m Creating UseCases Layer \033[0m"
dotnet new classlib -n $AppLayerName -o "$AppLayerPath" -f netcoreapp2.0

echo -e "\033[1;92m Creating UseCases unit tests \033[0m"
dotnet new xunit -n $AppLayerTestName -o "$AppLayerTestPath" -f netcoreapp2.0

echo -e "\033[1;92m Create Business Layer \033[0m"
dotnet new classlib -n $BLayerName -o "$BLayerPath" -f netcoreapp2.0

echo -e "\033[1;92m Create Business Layer unit tests \033[0m"
dotnet new xunit -n $BLTestName -o "$BLayerTestPath" -f netcoreapp2.0

echo -e "\033[1;92m Create Data Access Layer \033[0m"
dotnet new classlib -n $DALayerName -o "$DALayerPath" -f netcoreapp2.0

echo -e "\033[1;92m Create Entity Project \033[0m"
dotnet new classlib -n $EntitiesName -o "$EntitiesPath" -f netcoreapp2.0

if [ "$?" != "0" ]; then
	echo "Error create project!" 1>&2
	exit 1
fi

echo -e "\033[1;92m Adding  gitignore \033[0m"
curl -o $gitIgnorePath 'https://raw.githubusercontent.com/github/gitignore/master/VisualStudio.gitignore'

echo -e "\033[1;92m Adding all projects to solution \033[0m";
for refProj in `find $SolutionName -name '*.csproj'` ; do dotnet sln $SolutionFile add $refProj ;  done

echo -e "\033[1;92m Add reference \033[0m";
#reference web api test project
dotnet add $WebApiProj reference $WebApiMessagesProj
dotnet add $WebApiProj reference $AppLayerProj
dotnet add $WebApiProj reference $BLayerProj
dotnet add $WebApiProj reference $EntitiesProj
dotnet add $WebApiProj package Newtonsoft.Json --package-directory $SolutionName/packages

#reference Web Api Messages project
dotnet add $WebApiMessagesProj reference $EntitiesProj

#reference application api project
dotnet add $AppLayerProj reference $BLayerProj
dotnet add $AppLayerProj reference $EntitiesProj

#reference Business Layer project
dotnet add $BLayerProj reference $DALayerProj
dotnet add $BLayerProj reference $EntitiesProj

#reference Data Access project
dotnet add $DALayerProj reference $EntitiesProj
dotnet add $DALayerProj package Microsoft.EntityFrameworkCore --package-directory $SolutionName/packages

#reference web api test project
dotnet add $WebApiTestProj reference $WebApiProj
dotnet add $WebApiTestProj reference $AppLayerProj
dotnet add $WebApiTestProj reference $EntitiesProj

#reference app layer test project
dotnet add $AppLayerTestProj reference $AppLayerProj
dotnet add $AppLayerTestProj reference $BLayerProj
dotnet add $AppLayerTestProj reference $EntitiesProj

#reference business layer test project
dotnet add $BLayerTestProj reference $BLayerProj
dotnet add $BLayerTestProj reference $EntitiesProj
dotnet add $BLayerTestProj package Microsoft.EntityFrameworkCore.InMemory --package-directory $SolutionName/packages

echo -e "\033[1;92m Restoring packages \033[0m"
for proj in `find $SolutionName -name '*.csproj'` ; do dotnet restore $proj ;  done

echo -e "\033[1;92m Building solution \033[0m"
dotnet msbuild $SolutionFile

echo -e "\033[1;92m Opening in vsCode \033[0m"
code $SolutionName
