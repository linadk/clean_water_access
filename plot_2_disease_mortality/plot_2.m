% Plot 2 - Plots a bar graph showing both top/bottom performers in clean
% drinking water access in correlation to under five mortality.
% Associated files : WorldData_MortalityUnder5.csv , WASHDATA_BASIC_ACCESS_2020.csv  
% Satisfies rubrics : 2,3,4,5,6,7,8,9
% Primary Author : Lina Adkins

clear();clc();

% Run Entry Point
plot_data();

% Entry point, loads data with load_*data, then plots data sets with
function plot_data()

    % Our Query Parameters for years/countries we want
    five_low = ["Kenya" "Ethiopia" "Tanzania" "Republic of Congo" "Côte d’Ivoire"];
    five_low_iso = ["KEN" "ETH" "TZA" "COD" "CIV"];
    five_high = ["Australia","Mexico","United States", "Netherlands"];
    five_high_iso = ["AUS","MEX","USA", "NLD"];
    years_of_interest = [ 2018 2019 2020 ];
    
    % Load both trachoma data and washdata
    washdata = load_washdata("WASHDATA_BASIC_ACCESS_2020.csv");
    mortdata = load_mortdata("WorldData_MortalityUnder5.csv");
    
    % Plot five low countries
    plot_bar( five_low , five_low_iso , years_of_interest , [1 2] ,...
        "% of Population with Access to Improved Water Sources",...
        "Annual <5 Years Old Mortality" ,...
        washdata, mortdata );
    
    % Plot five high countries
    plot_bar( five_high, five_high_iso , years_of_interest , [3 4] ,...
        "% of Population with Access to Improved Water Sources",...
        "Annual <5 Years Old Mortality" ,...
        washdata, mortdata );
end

% Function that plots two specified subplots for the under five mortality data based on
% country and year range
function plot_bar( countries, countries_iso, years , subplots , title1 , title2 , washdata, mortdata )

    % Get our graphable data in year, % access, mortality cases format
    access_grouped = [];
    mortdata_grouped = [];
    
    % Loop through provided countries
    % Rubric #7 - Loops For/While
    for i=1:length(countries_iso) 
        
        % Query table for access data, then group by column by country
        % Rubric #8 - Work With Data As Array
        access = get_row(countries_iso(i),washdata,years);
        access_grouped(i,:) = access;
        
        % Grab Mortality Data, then group by column by country
        % Rubric #8 - Work WIth Data As Array
        idx = mortdata.ISO3 == countries_iso(i);
        mortdata_grouped(i,:) = [ mortdata(idx,:).YR2018 mortdata(idx,:).YR2019 NaN ];
        
        % Interpolate using fillmissing using different types of interp
        % Rubric #5 - Curve Fitting and Interpolation
        % based on data requirements.
        [access_grouped(i,:),tf] = fillmissing(access_grouped(i,:),'next','SamplePoints',years);
        [mortdata_grouped(i,:),tf] = fillmissing(mortdata_grouped(i,:),'linear','SamplePoints',years);
        disp(mortdata_grouped(i,:));

    end
    
    % Plot our bars
    % Rubric #4 - Graphing in MATLAB - Lines 67-95
    
    % Plot 1, Percentage of population
    plot_access = subplot(4,1,subplots(1));
    plot_mort = subplot(4,1,subplots(2));
    
    % Access Graph Plot
    bar(plot_access,years, access_grouped);
    legend(plot_access, countries,'Location','eastoutside');
    
    % Access Graph Setup
    title(plot_access,title1);
    xlim(plot_access, [ years(1)-0.5 years(end)+0.5]);
    xticks(plot_access,years);
    grid(plot_access, "on");
    ylim(plot_access,[-10 110]);
    ylabel("Percentage of population with access to improved water sources");
    xlabel("Sample Year");
    
    % Under 5 Mortality Plot
    bar(plot_mort, years, mortdata_grouped);

    % Under 5 Mortality Graph Setup
    title(plot_mort,title2);
    xlim(plot_mort, [ years(1)-0.5 , years(end)+0.5]);
    xticks(plot_mort,years);
    grid(plot_mort, "on");
    legend(plot_mort, countries, 'Location','eastoutside');
    ylim(plot_mort,'auto');
    ylabel("<5 y/o Deaths in Thousands");
    xlabel("Sample Year");
    
    % Text Output
    % Rubric #2 - output statements
    for i=1:length(countries)
        for j=1:length(years)
            fprintf(    "Country: %s Year: %d Percent: %f Mortality: %f thousand \n", ...
                        countries(i) , years(j), access_grouped(i,j) , mortdata_grouped(i,j) );
        end
    end

end

% Gets access data based on years of interest and country
function access = get_row(country_code,washdata,years_of_interest)
    
    access = [];
    
    % Loop through years of interest and get access data by country
    % Rubric #7 - Loops
    for( j=1:length(years_of_interest) )
        
        % Query Table For Access Info by year and country
        % Rubric #8 - Array Data
        idx = washdata.ISO3 == country_code & washdata.YEAR == years_of_interest(j);
        if idx == 0
            fprintf("%s %d access data isn't available!", country_code, years_of_interest(j));
        end
        
        access(j) = washdata(idx,:).PERCENT_BASIC_ACCESS;
    end
end

% Loads the washdata exported from CSV
% Rubric #3 - Reading Data
function data = load_washdata(filename)
    % Set up the Import Options and import the data
    opts = delimitedTextImportOptions("NumVariables", 4);

    % Specify range and delimiter
    opts.Delimiter = ",";

    % Specify column names and types
    opts.VariableNames = ["COUNTRY", "ISO3", "YEAR", "PERCENT_BASIC_ACCESS"];
    opts.VariableTypes = ["string", "string", "double", "double"];

    % Specify file level properties
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";

    % Specify variable properties
    opts = setvaropts(opts, ["COUNTRY", "ISO3"], "WhitespaceRule", "preserve");
    opts = setvaropts(opts, ["COUNTRY", "ISO3"], "EmptyFieldRule", "auto");

    % Import the data
    % Rubric #3 - Reading Data
    data = readtable(filename, opts);
end

% Load mortality data from CSV generated from excel
% Rubric #3 - Reading Data
function data = load_mortdata(filename)


    % Import options
    opts = delimitedTextImportOptions("NumVariables", 16, "Encoding", "UTF-8");

    % Range
    opts.Delimiter = ",";

    % Columns
    opts.VariableNames = ["SeriesName", "SeriesCode", "Country", "ISO3", "YR1990", "YR2000", "YR2011", "YR2012", "YR2013", "YR2014", "YR2015", "YR2016", "YR2017", "YR2018", "YR2019", "YR2020"];
    opts.VariableTypes = ["categorical", "categorical", "string", "string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "categorical"];

    % Varnames
    opts = setvaropts(opts, ["Country", "ISO3"], "WhitespaceRule", "preserve");
    opts = setvaropts(opts, ["SeriesName", "SeriesCode", "Country", "ISO3", "YR2020"], "EmptyFieldRule", "auto");

    % Import the data
    data = readtable(filename, opts);
end