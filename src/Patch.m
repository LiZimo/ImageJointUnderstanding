classdef Patch < dynamicprops
    
    properties (GetAccess = public, SetAccess = private)
        % Basic properties that every instance of the Patch class has.        
        source_image    %   (Image)           -    Image over which the patch was sampled.
        
        corners         %   (1 x 4 matrix)    -    x-y coordinates wrt. source image, corresponding to the corners 
                        %                          of the rectangular patch. They are [xmin, ymin, xmax, ymax]
    end
    
    
    methods (Access = public)
        % Class constructror
        function obj = Patch(src_img, corners)
            if nargin == 0
                obj.source_image = [];              %TODO-P replace with Image.
                obj.corners      = zeros(1,4);
            else
                obj.source_image = src_img;
                obj.corners      = corners;
            end
        end
        
        function [xmin, ymin, xmax, ymax] = get_corners(obj)
            % Getter of object's property 'corners' corresponding to the 4 extema of
            % the x-y coordinates of the patch.
            xmin = obj.corners(1);
            ymin = obj.corners(2);
            xmax = obj.corners(3);
            ymax = obj.corners(4);
        end
    
        function [F] = plot(obj)
         % Plots the boundary of the patch on its source image.
            shape_inserter = vision.ShapeInserter('LineWidth', 4);         
            [xmin, ymin, xmax, ymax] = obj.get_corners();
            rectangle = int32([xmin ymin (xmax - xmax) (ymax - ymin)]);
            im_out    = step(shape_inserter, obj.source_image, rectangle);            
            image(im_out);
        end

        
        
                  
%         function left_down_corner ()       % TODO-Z
%         function left_up_corner ()
%         function right_down_corner ()
%         function right_up_corner ()
    end
   
    methods (Static, Access = private)
    end
    

end