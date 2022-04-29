classdef rs_working_demo < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GenerateMovieButton           matlab.ui.control.Button
        SinusoidalMotionSpeedSpinnerLabel  matlab.ui.control.Label
        SinusoidalMotionSpeedSpinner  matlab.ui.control.Spinner
        RotatingSphereStimulusGeneratorLabel  matlab.ui.control.Label
        NumberofDotsEditFieldLabel    matlab.ui.control.Label
        NumberofDotsEditField         matlab.ui.control.NumericEditField
        SphereRadiusEditFieldLabel    matlab.ui.control.Label
        SphereRadiusEditField         matlab.ui.control.NumericEditField
        DirectoryButton               matlab.ui.control.Button
        DotSizeEditFieldLabel         matlab.ui.control.Label
        DotSizeEditField              matlab.ui.control.NumericEditField
        PixelsLabel                   matlab.ui.control.Label
        PixelsLabel_2                 matlab.ui.control.Label
        DegreesLabel                  matlab.ui.control.Label
        FlatPlaneWobbleSpeedSpinnerLabel  matlab.ui.control.Label
        FlatPlaneWobbleSpeedSpinner   matlab.ui.control.Spinner
        DegreesLabel_2                matlab.ui.control.Label
    end

    % Callback functions of each component
    methods (Access = private)

        % Generate movie when the button is pressed
        function GenerateMovieButtonPushed(app, event)
            
            % Default PTB settings
            PsychDefaultSetup(2);
            
            % Skip sync tests 
            Screen('Preference', 'SkipSyncTests', 2);
            screenid = max(Screen('Screens'));
            
            % Determine the values of black and white
            black = BlackIndex(screenid);
            white = WhiteIndex(screenid);
            
            % Set up screen
            [window, windowRect] = PsychImaging('OpenWindow', screenid, black, [], 32, 2);
            [center(1), center(2)] = RectCenter(windowRect);  % Determine screen center and dimensions
            
            Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
            
            % Set sphere dimensions
            numDots = app.NumberofDotsEditField.Value; % number of dots
            % r = app.SphereRadiusEditField.Value; % radius
            % r_pix = r * pixPerCm; % radius in pixels
            r_pix = app.SphereRadiusEditField.Value; % radius in pixels, from entered value
            angles = rand(1, numDots) .* 360; % starting angle with respect to the origin
            dots_Y0 = (rand(1, numDots) .* 2 - 1) .* r_pix; % starting y-coordinates
            dotSizePixels = app.DotSizeEditField.Value; % dot size in pixels, from entered value
            rotationSpeed = app.SinusoidalMotionSpeedSpinner.Value; % speed, from entered value
            
            % Set starting angle and frame
            theta = 0; 
            frames = 0;
            dots_X = zeros(1, numDots);
            dots_Y = zeros(1, numDots);
            
            % Initialize movie
            movie = Screen('CreateMovie', window, 'rotating_sphere.mov');
            
            tic;
            while toc <= 30 % maybe getSecs will work better but this is fine for now
                
                % Set x coordinates at 0 degree
                dots_X0 = sin(angles .* (pi / 180)) .* sqrt(r_pix.^2 - dots_Y0.^2);
                
                % Set intervals for clockwise orientation change
                frames = frames + 1; % dumb way of doing this but screen(framerate) doesn't work on mac os
                if mod(frames, 400) > 280
                    theta = theta + rand * app.FlatPlaneWobbleSpeedSpinner.Value; % orientation updates every 3 seconds or so
                end
                
                % Set intervals for counter-clockwise orientation change
                if mod(frames, 600) > 480
                    theta = theta - rand * app.FlatPlaneWobbleSpeedSpinner.Value;
                end
                
                % Create the matrix for rotating axes
                coords =[cosd(theta), -sind(theta); sind(theta), cosd(theta)];
                
                % Get new x- and y-coordinates
                for i = 1:numDots
                    dots_XY0 = [dots_X0(i), dots_Y0(i)] * coords;
                    dots_X(i) = dots_XY0(1);
                    dots_Y(i) = dots_XY0(2);
                end

                % Draw the dots
                Screen('DrawDots', window, [dots_X; dots_Y], dotSizePixels, white, center, 2);
                Screen('Flip', window);
                angles = angles + rotationSpeed;
                
                % Add a frame to the movie
                Screen('AddFrameToMovie', window); 
                
            %     % Grab this frame and save as a png file
            %     current_display = Screen('GetImage', window);
           
                
            end
            
            % Finalize movie file
            Screen('FinalizeMovie', movie);
            sca;
        end
        
 %     imwrite(current_display, 'rs' + string(frames) + '.png');
 
        % Open finder window to browse directories
        function DirectoryButtonPushed(app, event)
            new_dir = uigetdir(matlabroot, 'MATLAB Root Folder');
            cd (new_dir);
        end
    end

    % Initialize ui components
    methods (Access = private)

        % Create ui components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 546 532];
            app.UIFigure.Name = 'MATLAB App';

            % Create GenerateMovieButton
            app.GenerateMovieButton = uibutton(app.UIFigure, 'push');
            app.GenerateMovieButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateMovieButtonPushed, true);
            app.GenerateMovieButton.FontName = 'Myriad Pro';
            app.GenerateMovieButton.FontSize = 16;
            app.GenerateMovieButton.Position = [207 57 142 36];
            app.GenerateMovieButton.Text = 'Generate Movie';

            % Create SinusoidalMotionSpeedSpinnerLabel
            app.SinusoidalMotionSpeedSpinnerLabel = uilabel(app.UIFigure);
            app.SinusoidalMotionSpeedSpinnerLabel.HorizontalAlignment = 'right';
            app.SinusoidalMotionSpeedSpinnerLabel.FontName = 'Myriad Pro';
            app.SinusoidalMotionSpeedSpinnerLabel.FontSize = 16;
            app.SinusoidalMotionSpeedSpinnerLabel.Position = [58 236 171 22];
            app.SinusoidalMotionSpeedSpinnerLabel.Text = 'Sinusoidal Motion Speed';

            % Create SinusoidalMotionSpeedSpinner
            app.SinusoidalMotionSpeedSpinner = uispinner(app.UIFigure);
            app.SinusoidalMotionSpeedSpinner.Step = 0.1;
            app.SinusoidalMotionSpeedSpinner.FontName = 'Myriad Pro';
            app.SinusoidalMotionSpeedSpinner.FontSize = 16;
            app.SinusoidalMotionSpeedSpinner.Position = [291 236 102 22];
            app.SinusoidalMotionSpeedSpinner.Value = 0.5;

            % Create RotatingSphereStimulusGeneratorLabel
            app.RotatingSphereStimulusGeneratorLabel = uilabel(app.UIFigure);
            app.RotatingSphereStimulusGeneratorLabel.FontName = 'Myriad Pro';
            app.RotatingSphereStimulusGeneratorLabel.FontSize = 18;
            app.RotatingSphereStimulusGeneratorLabel.FontWeight = 'bold';
            app.RotatingSphereStimulusGeneratorLabel.Position = [128 451 299 23];
            app.RotatingSphereStimulusGeneratorLabel.Text = 'Rotating Sphere Stimulus Generator';

            % Create NumberofDotsEditFieldLabel
            app.NumberofDotsEditFieldLabel = uilabel(app.UIFigure);
            app.NumberofDotsEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberofDotsEditFieldLabel.FontName = 'Myriad Pro';
            app.NumberofDotsEditFieldLabel.FontSize = 16;
            app.NumberofDotsEditFieldLabel.Position = [88 314 112 22];
            app.NumberofDotsEditFieldLabel.Text = 'Number of Dots';

            % Create NumberofDotsEditField
            app.NumberofDotsEditField = uieditfield(app.UIFigure, 'numeric');
            app.NumberofDotsEditField.Limits = [1 5000];
            app.NumberofDotsEditField.RoundFractionalValues = 'on';
            app.NumberofDotsEditField.FontName = 'Myriad Pro';
            app.NumberofDotsEditField.FontSize = 16;
            app.NumberofDotsEditField.Position = [291 314 100 22];
            app.NumberofDotsEditField.Value = 500;

            % Create SphereRadiusEditFieldLabel
            app.SphereRadiusEditFieldLabel = uilabel(app.UIFigure);
            app.SphereRadiusEditFieldLabel.HorizontalAlignment = 'right';
            app.SphereRadiusEditFieldLabel.FontName = 'Myriad Pro';
            app.SphereRadiusEditFieldLabel.FontSize = 16;
            app.SphereRadiusEditFieldLabel.Position = [94 275 100 22];
            app.SphereRadiusEditFieldLabel.Text = 'Sphere Radius';

            % Create SphereRadiusEditField
            app.SphereRadiusEditField = uieditfield(app.UIFigure, 'numeric');
            app.SphereRadiusEditField.Limits = [100 1000];
            app.SphereRadiusEditField.RoundFractionalValues = 'on';
            app.SphereRadiusEditField.FontName = 'Myriad Pro';
            app.SphereRadiusEditField.FontSize = 16;
            app.SphereRadiusEditField.Position = [291 275 100 22];
            app.SphereRadiusEditField.Value = 300;

            % Create DirectoryButton
            app.DirectoryButton = uibutton(app.UIFigure, 'push');
            app.DirectoryButton.ButtonPushedFcn = createCallbackFcn(app, @DirectoryButtonPushed, true);
            app.DirectoryButton.FontName = 'Myriad Pro';
            app.DirectoryButton.FontSize = 16;
            app.DirectoryButton.Position = [207 108 142 36];
            app.DirectoryButton.Text = 'Directory';

            % Create DotSizeEditFieldLabel
            app.DotSizeEditFieldLabel = uilabel(app.UIFigure);
            app.DotSizeEditFieldLabel.HorizontalAlignment = 'right';
            app.DotSizeEditFieldLabel.FontName = 'Myriad Pro';
            app.DotSizeEditFieldLabel.FontSize = 16;
            app.DotSizeEditFieldLabel.Position = [114 353 60 22];
            app.DotSizeEditFieldLabel.Text = 'Dot Size';

            % Create DotSizeEditField
            app.DotSizeEditField = uieditfield(app.UIFigure, 'numeric');
            app.DotSizeEditField.Limits = [1 20];
            app.DotSizeEditField.FontName = 'Myriad Pro';
            app.DotSizeEditField.FontSize = 16;
            app.DotSizeEditField.Position = [291 353 100 22];
            app.DotSizeEditField.Value = 8;

            % Create PixelsLabel
            app.PixelsLabel = uilabel(app.UIFigure);
            app.PixelsLabel.FontName = 'Myriad Pro';
            app.PixelsLabel.FontSize = 16;
            app.PixelsLabel.Position = [454 353 43 22];
            app.PixelsLabel.Text = 'Pixels';

            % Create PixelsLabel_2
            app.PixelsLabel_2 = uilabel(app.UIFigure);
            app.PixelsLabel_2.FontName = 'Myriad Pro';
            app.PixelsLabel_2.FontSize = 16;
            app.PixelsLabel_2.Position = [454 275 43 22];
            app.PixelsLabel_2.Text = 'Pixels';

            % Create DegreesLabel
            app.DegreesLabel = uilabel(app.UIFigure);
            app.DegreesLabel.FontName = 'Myriad Pro';
            app.DegreesLabel.FontSize = 16;
            app.DegreesLabel.Position = [445 236 61 22];
            app.DegreesLabel.Text = 'Degrees';

            % Create FlatPlaneWobbleSpeedSpinnerLabel
            app.FlatPlaneWobbleSpeedSpinnerLabel = uilabel(app.UIFigure);
            app.FlatPlaneWobbleSpeedSpinnerLabel.HorizontalAlignment = 'right';
            app.FlatPlaneWobbleSpeedSpinnerLabel.FontName = 'Myriad Pro';
            app.FlatPlaneWobbleSpeedSpinnerLabel.FontSize = 16;
            app.FlatPlaneWobbleSpeedSpinnerLabel.Position = [58 197 171 22];
            app.FlatPlaneWobbleSpeedSpinnerLabel.Text = 'Flat Plane Wobble Speed';

            % Create FlatPlaneWobbleSpeedSpinner
            app.FlatPlaneWobbleSpeedSpinner = uispinner(app.UIFigure);
            app.FlatPlaneWobbleSpeedSpinner.Step = 0.1;
            app.FlatPlaneWobbleSpeedSpinner.Limits = [0.1 1];
            app.FlatPlaneWobbleSpeedSpinner.FontName = 'Myriad Pro';
            app.FlatPlaneWobbleSpeedSpinner.FontSize = 16;
            app.FlatPlaneWobbleSpeedSpinner.Position = [291 197 102 22];
            app.FlatPlaneWobbleSpeedSpinner.Value = 0.5;

            % Create DegreesLabel_2
            app.DegreesLabel_2 = uilabel(app.UIFigure);
            app.DegreesLabel_2.FontName = 'Myriad Pro';
            app.DegreesLabel_2.FontSize = 16;
            app.DegreesLabel_2.Position = [445 197 61 22];
            app.DegreesLabel_2.Text = 'Degrees';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = rs_working_demo

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end