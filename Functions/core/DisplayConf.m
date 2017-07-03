classdef DisplayConf
    
    % Define class properties
    properties(GetAccess = public, SetAccess = public)
        wscr = 0;
        pixelsize = 32;
        hz = 60;
        bgcol = [0 0 0];
        distance = 570;
        rect;
        Color;
        mode = true;    
        w;
        screenNum;
        framerate;
        width;
        height;
        displaysize = [];
        widthScr;
        heightScr;
        xc;
        yc;
        screensize;
        displaySize;
        flipInt;
        ifi;
        skip;
    end
    
    % Class methods and constructor
    methods(Access = public)
        
        % Constructor
        function this = DisplayConf(varargin)
            
            property_argin = varargin;
            while length(property_argin) >= 1,
                property = property_argin{1};
                value = property_argin{2};
                property_argin = property_argin(3:end);

                switch lower(property)
                    case 'wscr'
                        this.wscr = value;
                    case 'bgcol'
                        this.bgcol = value;
                    case 'pixelsize'
                        this.pixelsize = value;
                    case 'hz'
                        this.hz = value;
                    case 'rect'
                        this.rect = value;
                    case 'displaysize'
                        this.displaysize = value;
                    case 'distance'
                        this.distance = value;
                    case 'mode'
                        this.mode = value;
                    case 'skip'
                        this.skip = value;
                    otherwise
                        disp((property));
                        error('%s: Wrong argument name',lower(property));
                end
            end  
            
            this = this.DisplayConfRoutines();
            
            if this.mode == 0
                this.closeroutine();
            end
        end
        
        % Routines
        function this = DisplayConfRoutines(this)
            this = this.DisplayParams();
            this = this.openwindow();
            this = this.GetColorSettings();
            this.SetPref();
        end
        
    end
    
    % Private methods
    methods(Access = private)
        % Set & open a PTB window
        function this = DisplayParams(this)
            
            % Display screen parameters
            screens = Screen('Screens');
            if this.wscr > numel(screens)
                this.wscr = 1;
            end
            this.screenNum = screens(this.wscr);
            this.framerate = Screen('FrameRate', this.screenNum);
            [this.width, this.height] = Screen('WindowSize', this.screenNum);
            if isempty(this.displaysize)
                [this.widthScr, this.heightScr] = Screen('DisplaySize',this.screenNum);
            else
                this.widthScr = this.displaysize(1);
                this.heightScr = this.displaysize(2);
            end
            this.screensize = [this.width, this.height];
            this.displaySize = [this.widthScr, this.heightScr];

            if isempty(this.rect)
                this.rect = Screen('Rect',this.screenNum);
            else
                switch lower(this.rect)
                    case 'up'
                        this.rect = [0 0 this.screensize(1) this.screensize(2)/2];
                    case 'down'
                        this.rect = [0 this.screensize(2)/2 this.screensize(1) this.screensize(2)];
                    case 'left'
                        this.rect = [0 0 this.screensize(1)/2 this.screensize(2)];
                    case 'right'
                        this.rect = [this.screensize(1)/2 0 this.screensize(1) this.screensize(2)];
                end
            end
            this.xc = round(this.rect(3)/2);
            this.yc = round(this.rect(4)/2);
        end
        
        function this = openwindow(this)
            % Test openGL readyness
            AssertOpenGL;
            if this.skip
                Screen('Preference', 'SkipSyncTests', 1);
            end

            % open a window of particular size and refresh rate
            pixelSizes = Screen('PixelSizes',this.screenNum);
            if max(pixelSizes)<this.pixelsize
                fprintf('Sorry, I need a screen that supports %d-bit pixelSize.\n', this.pixelsize);
                return;
            end

            [this.w, this.rect] = Screen('OpenWindow',this.screenNum,this.bgcol,this.rect,this.pixelsize);            
            % Set priority to its maximum
            max(Priority);
 
            % Measure of refresh rate
            this.flipInt = Screen('GetFlipInterval', this.w);
            this.ifi = 1/this.flipInt;

            Priority(0);
        end
        
        % Set color default
        function this = GetColorSettings(this)
            % index couleur
            this.Color.white = WhiteIndex(this.w); % pixel value for white
            this.Color.black = BlackIndex(this.w); % pixel value for black
            this.Color.gray = (this.Color.white+this.Color.black)/2;
            this.Color.inc = this.Color.white-this.Color.gray;
            this.Color.red = [200 0 0];
            this.Color.green = [0 200 0];
            this.Color.blue = [0 0 200];
            this.Color.bgcol = this.bgcol;
        end
        
        % Set display preferences
        function SetPref(this)

            %% Transparence
            Screen('BlendFunction',this.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

            %% Screen preferences
            Screen('Preference', 'TextAntiAliasing', 1);
            Screen('Preference', 'DefaultFontSize', 16);
            Screen('Preference', 'DefaultFontStyle', 0);
            Screen('Preference', 'Verbosity', 1);
            Screen('Preference', 'DefaultFontName','Arial');

            if strcmp(computer,'PCWIN')
                Screen('Preference', 'SuppressAllWarnings', 1);
            end
        end
        
        % Close & clean-up routine
        function closeroutine(this)
            Screen('CloseAll');
            clear mex;
            ShowCursor;
            ListenChar();
        end
        
    end
    
end