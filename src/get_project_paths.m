function [data_path, code_path] = get_project_paths(project_name)
% Computes the personalized file paths for the data and external code libraries assosicated with a specified project.
% Input:
%           project_name - (str) A string specifying the project's name.
% Output:   
%           data_path    - (str) File path to project's data repository.
%           code_path    - (str) File path to project's (external) code repository.

    if ismac
        [~, name] = system('scutil --get ComputerName');
    else
        [~, name] = system('hostname');
    end

    if strcmp(name, 'optasMacPro')
        if strcmp(project_name, 'ImageJointUnderstanding')
            data_path = '/Users/optas/Dropbox/with_others/zimo - peter - panos/Joint_Image_Understanding/Data/';
            code_path = '/Users/optas/Dropbox/matlab_projects/External_Packages/';
        end
    else
        data_path = 'Zimo add here';
        code_path = 'Zimo add here';
    end
    
end