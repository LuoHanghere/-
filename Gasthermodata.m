classdef Gasthermodata < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        EditField_4        matlab.ui.control.NumericEditField
        Label_9            matlab.ui.control.Label
        Button             matlab.ui.control.Button
        EditField_3        matlab.ui.control.NumericEditField
        Label_7            matlab.ui.control.Label
        EditField_2        matlab.ui.control.NumericEditField
        Label_8            matlab.ui.control.Label
        EditField          matlab.ui.control.NumericEditField
        Label_6            matlab.ui.control.Label
        barEditField       matlab.ui.control.NumericEditField
        barEditFieldLabel  matlab.ui.control.Label
        KEditField         matlab.ui.control.NumericEditField
        KEditFieldLabel    matlab.ui.control.Label
        DropDown_5         matlab.ui.control.DropDown
        Label_5            matlab.ui.control.Label
        DropDown_4         matlab.ui.control.DropDown
        Label_4            matlab.ui.control.Label
        DropDown_3         matlab.ui.control.DropDown
        Label_3            matlab.ui.control.Label
        DropDown_2         matlab.ui.control.DropDown
        Label_2            matlab.ui.control.Label
        DropDown           matlab.ui.control.DropDown
        Label              matlab.ui.control.Label
    end

    properties (Access = private)
        GasData  % 存储气体热力学参数数据
    end

    methods (Access = private)

        function loadData(app)
            % 从.mat文件加载数据
            app.GasData = load('GasThermoData.mat');
        end

        function value = interpolateData(~, data, temperature, pressure)
            % 插值计算热力学参数
            temperatures = 200:10:2500;
            pressures = 1:60;

            [~, tempIndex] = min(abs(temperatures - temperature));
            [~, pressIndex] = min(abs(pressures - pressure));

            if tempIndex > 1 && tempIndex < length(temperatures) && ...
               pressIndex > 1 && pressIndex < length(pressures)
                % 双线性插值
                t1 = temperatures(tempIndex-1);
                t2 = temperatures(tempIndex);
                p1 = pressures(pressIndex-1);
                p2 = pressures(pressIndex);

                q11 = data(tempIndex-1, pressIndex-1);
                q21 = data(tempIndex, pressIndex-1);
                q12 = data(tempIndex-1, pressIndex);
                q22 = data(tempIndex, pressIndex);

                x = (temperature - t1) / (t2 - t1);
                y = (pressure - p1) / (p2 - p1);

                value = (1-x)*(1-y)*q11 + x*(1-y)*q21 + (1-x)*y*q12 + x*y*q22;
            else
                value = data(tempIndex, pressIndex);
            end
        end

        function result = calculateMixedProperty(app, property, temperature, pressure, gases, fractions)
            % 计算混合气体的热力学参数
            result = 0;
            for i = 1:length(gases)
                if ~isempty(gases{i})
                    gasData = app.GasData.(gases{i}).(property);
                    gasValue = app.interpolateData(gasData, temperature, pressure);
                    result = result + fractions(i) * gasValue;
                end
            end
        end

    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.loadData();
        end

        % Button pushed function: Button
        function ButtonPushed(app, ~)
            property = app.DropDown.Value;
            temperature = app.KEditField.Value;
            pressure = app.barEditField.Value;
            
            gases = {app.DropDown_3.Value, app.DropDown_4.Value, app.DropDown_5.Value};
            fractions = [app.EditField.Value, app.EditField_2.Value, app.EditField_3.Value];
            
            % 检查摩尔分数之和是否为1
            if abs(sum(fractions) - 1) > 1e-6
                app.EditField_4.Value = NaN;
                errordlg('Error: Mole fractions must sum to 1', 'Input Error');
                return;
            end
            
            result = app.calculateMixedProperty(property, temperature, pressure, gases, fractions);
            app.EditField_4.Value = result;
        end

        % Value changed function: DropDown_2
        function DropDown_2ValueChanged(app, ~)
            value = app.DropDown_2.Value;
            switch value
                case '1类'
                    app.DropDown_4.Enable = 'off';
                    app.DropDown_5.Enable = 'off';
                    app.EditField_2.Enable = 'off';
                    app.EditField_3.Enable = 'off';
                case '2类'
                    app.DropDown_4.Enable = 'on';
                    app.DropDown_5.Enable = 'off';
                    app.EditField_2.Enable = 'on';
                    app.EditField_3.Enable = 'off';
                case '3类'
                    app.DropDown_4.Enable = 'on';
                    app.DropDown_5.Enable = 'on';
                    app.EditField_2.Enable = 'on';
                    app.EditField_3.Enable = 'on';
            end
        end

    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 453 519];
            app.UIFigure.Name = 'MATLAB App';

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [27 406 65 22];
            app.Label.Text = '热力学参数';

            % Create DropDown
            app.DropDown = uidropdown(app.UIFigure);
            app.DropDown.Items = {'density', 'heat_ratio', 'thermal_conductivity', 'viscosity'};
            app.DropDown.Position = [107 406 100 22];
            app.DropDown.Value = 'density';

            % Create Label_2
            app.Label_2 = uilabel(app.UIFigure);
            app.Label_2.HorizontalAlignment = 'right';
            app.Label_2.Position = [252 406 53 22];
            app.Label_2.Text = '气体数量';

            % Create DropDown_2
            app.DropDown_2 = uidropdown(app.UIFigure);
            app.DropDown_2.Items = {'1类', '2类', '3类'};
            app.DropDown_2.Position = [320 406 94 22];
            app.DropDown_2.Value = '1类';
            app.DropDown_2.ValueChangedFcn = createCallbackFcn(app, @DropDown_2ValueChanged, true);

            % Create Label_3
            app.Label_3 = uilabel(app.UIFigure);
            app.Label_3.HorizontalAlignment = 'right';
            app.Label_3.Position = [57 276 36 22];
            app.Label_3.Text = '气体1';

            % Create DropDown_3
            app.DropDown_3 = uidropdown(app.UIFigure);
            app.DropDown_3.Items = {'Air', 'nitrogen', 'helium ', 'argon', 'carbondioxide'};
            app.DropDown_3.Position = [108 272 99 30];
            app.DropDown_3.Value = 'Air';

            % Create Label_4
            app.Label_4 = uilabel(app.UIFigure);
            app.Label_4.HorizontalAlignment = 'right';
            app.Label_4.Position = [57 231 36 22];
            app.Label_4.Text = '气体2';

            % Create DropDown_4
            app.DropDown_4 = uidropdown(app.UIFigure);
            app.DropDown_4.Items = {'Air', 'nitrogen', 'helium ', 'argon', 'carbondioxide'};
            app.DropDown_4.Position = [108 227 99 30];
            app.DropDown_4.Value = 'Air';
            app.DropDown_4.Enable = 'off';

            % Create Label_5
            app.Label_5 = uilabel(app.UIFigure);
            app.Label_5.HorizontalAlignment = 'right';
            app.Label_5.Position = [57 183 36 22];
            app.Label_5.Text = '气体3';

            % Create DropDown_5
            app.DropDown_5 = uidropdown(app.UIFigure);
            app.DropDown_5.Items = {'Air', 'nitrogen', 'helium ', 'argon', 'carbondioxide'};
            app.DropDown_5.Position = [108 179 99 30];
            app.DropDown_5.Value = 'Air';
            app.DropDown_5.Enable = 'off';

            % Create KEditFieldLabel
            app.KEditFieldLabel = uilabel(app.UIFigure);
          app.KEditFieldLabel.HorizontalAlignment = 'right';
            app.KEditFieldLabel.Position = [35 352 53 22];
            app.KEditFieldLabel.Text = '温度（K)';
                      

            % Create KEditField
            app.KEditField = uieditfield(app.UIFigure, 'numeric');
            app.KEditField.Position = [103 352 100 22];

            % Create barEditFieldLabel
            app.barEditFieldLabel = uilabel(app.UIFigure);
            app.barEditFieldLabel.HorizontalAlignment = 'right';
            app.barEditFieldLabel.Position = [241 352 62 22];
            app.barEditFieldLabel.Text = '压强（bar)';

            % Create barEditField
            app.barEditField = uieditfield(app.UIFigure, 'numeric');
             app.barEditField.Limits = [1 60];
            app.barEditField.Position = [318 352 100 22];
                        app.barEditField.Value = 1;

            % Create Label_6
            app.Label_6 = uilabel(app.UIFigure);
            app.Label_6.HorizontalAlignment = 'right';
            app.Label_6.Position = [229 274 60 22];
            app.Label_6.Text = '摩尔占比1';

            % Create EditField
            app.EditField = uieditfield(app.UIFigure, 'numeric');
            app.EditField.Position = [304 272 88 26];

            % Create Label_8
            app.Label_8 = uilabel(app.UIFigure);
            app.Label_8.HorizontalAlignment = 'right';
            app.Label_8.Position = [229 233 60 22];
            app.Label_8.Text = '摩尔占比2';

            % Create EditField_2
            app.EditField_2 = uieditfield(app.UIFigure, 'numeric');
            app.EditField_2.Position = [304 231 88 26];
            app.EditField_2.Enable = 'off';

            % Create Label_7
            app.Label_7 = uilabel(app.UIFigure);
            app.Label_7.HorizontalAlignment = 'right';
            app.Label_7.Position = [229 184 60 22];
            app.Label_7.Text = '摩尔占比3';

            % Create EditField_3
            app.EditField_3 = uieditfield(app.UIFigure, 'numeric');
            app.EditField_3.Position = [304 182 88 26];
            app.EditField_3.Enable = 'off';

            % Create Button
            app.Button = uibutton(app.UIFigure, 'push');
            app.Button.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.Button.Position = [288 104 120 30];
            app.Button.Text = '计算';

            % Create Label_9
            app.Label_9 = uilabel(app.UIFigure);
            app.Label_9.HorizontalAlignment = 'right';
            app.Label_9.Position = [73 108 29 22];
            app.Label_9.Text = '结果';

            % Create EditField_4
            app.EditField_4 = uieditfield(app.UIFigure, 'numeric');
            app.EditField_4.ValueDisplayFormat = '%.9f';
            app.EditField_4.Position = [117 100 125 38];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Gasthermodata

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

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