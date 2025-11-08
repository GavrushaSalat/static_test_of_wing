% Основные определения

%1-й уровень - точки крепления к крылу
%2-й уровень- точки крепления рычагов, соеденяющие точки крепления к крылу
%3-й уровень точки крепления рычагов, соеденяющие точки 2-го уровня
%4-й уровень точка за которую подвешиваеться груз


% Построение системы рычагов для распределения нагрузки на крыло
% Входные параметры:
% a - постоянная составляющая нагрузки

% Построение системы рычагов для распределения нагрузки на крыло
% Входные параметры:
% a - постоянная составляющая нагрузки
% b - линейная составляющая нагрузки% 1. Базовые параметры
L = 1; % Длина крыла
n_points = 8; % Количество точек крепления
  
% Координаты точек крепления к крылу (уровень 1)
x1 = linspace(0, L, n_points);
  
% 2. Расчет распределенной нагрузки
% Функция распределенной нагрузки
a=0;
b=2;
    
% Полная сила и момент
F_total = integral(q, 0, L);
M_total = integral(@(x) q(x).*x, 0, L);
    
fprintf('Полная сила F = %.4f\n', F_total);
fprintf('Момент M = %.4f\n', M_total);
%% 3. Расчет сосредоточенных сил R_i
% Решение системы для коэффициентов A и B
sum_x = sum(x1);
sum_x2 = sum(x1.^2);
    
% Матрица системы
M = [n_points, sum_x; sum_x, sum_x2];
rhs = [F_total; M_total];
   
coeffs = M \ rhs;
A = coeffs(1);
B = coeffs(2);
    
% Сосредоточенные силы
R = A + B * x1;    
fprintf('\nКоэффициенты:\n');
fprintf('A = %.4f, B = %.4f\n', A, B);
% 4. Расчет координат рычагов уровня 2
x2 = zeros(1, 4);
F_level2 = zeros(1, 4);
    
for j = 1:4
i1 = 2*j - 1;
i2 = 2*j;
        
R1 = R(i1);
R2 = R(i2);
x1_val1 = x1(i1);
x1_val2 = x1(i2);
        
% Координата точки подвеса (центр тяжести)
x2(j) = (R1*x1_val1 + R2*x1_val2) / (R1 + R2);
F_level2(j) = R1 + R2;
        
fprintf('x2_%d = %.4f, F_%d = %.4f\n', j, x2(j), j, F_level2(j));
end
    
%% 5. Расчет координат рычагов уровня 3
x3 = zeros(1, 2);
F_level3 = zeros(1, 2);
for k = 1:2
j1 = 2*k - 1;
j2 = 2*k;
        
F1 = F_level2(j1);
F2 = F_level2(j2);
x2_val1 = x2(j1);
x2_val2 = x2(j2);
        
x3(k) = (F1*x2_val1 + F2*x2_val2) / (F1 + F2);
F_level3(k) = F1 + F2;
        
fprintf('x3_%d = %.4f, F_%d = %.4f\n', k, x3(k), k, F_level3(k));
end
    
% 6. Расчет координаты точки подвеса груза (уровень 4)
F1_level3 = F_level3(1);
F2_level3 = F_level3(2);
x3_val1 = x3(1);
x3_val2 = x3(2);
    
x4 = (F1_level3*x3_val1 + F2_level3*x3_val2) / (F1_level3 + F2_level3);
    
fprintf('\nТочка подвеса груза:\n');
fprintf('x4 = %.4f\n', x4);
    
% 7. Визуализация
figure('Position', [100, 100, 1200, 800]);
    
% 7.1 Распределенная нагрузка
subplot(2,3,1);
x_plot = linspace(0, L, 100);
q_plot = q(x_plot);
plot(x_plot, q_plot, 'b-', 'LineWidth', 2);
hold on;
plot(x1, A + B*x1, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
xlabel('Координата x');
ylabel('Нагрузка q(x)');
title('Распределенная нагрузка');
legend('q(x) = a + bx', 'Аппроксимация', 'Location', 'best');
grid on;
    
% 7.2 Сосредоточенные силы
subplot(2,3,2);
stem(x1, R, 'filled', 'LineWidth', 2);
xlabel('Координата x');
ylabel('Сила R_i');
title('Сосредоточенные силы');
grid on;
    
% 7.3 Система рычагов - схема
subplot(2,3,3);
plot_lever_system(x1, x2, x3, x4, R, F_level2, F_level3);
title('Схема системы рычагов');
    
% 7.4 Проверка - равнодействующая и момент
subplot(2,3,4);
% Расчетная равнодействующая
F_calc = sum(R);
M_calc = sum(R .* x1);
    
bar([F_total, F_calc; M_total, M_calc]);
set(gca, 'XTickLabel', {'Сила F', 'Момент M'});
ylabel('Значение');
legend('Теоретическое', 'Расчетное', 'Location', 'best');
title('Проверка эквивалентности');
grid on;
    
% 7.5 Погрешность
subplot(2,3,5);
error_F = abs(F_total - F_calc) / F_total * 100;
error_M = abs(M_total - M_calc) / M_total * 100;
    
bar([error_F; error_M]);
ylabel('Погрешность (%)');
set(gca, 'XTickLabel', {'Сила F', 'Момент M'});
title('Относительная погрешность');
grid on;
    
% 7.6 Итоговая информация
subplot(2,3,6);
axis off;
text(0.1, 0.9, sprintf('Параметры нагрузки:'), 'FontSize', 12, 'FontWeight', 'bold');
text(0.1, 0.8, sprintf('a = %.2f', a), 'FontSize', 11);
text(0.1, 0.7, sprintf('b = %.2f', b), 'FontSize', 11);
text(0.1, 0.6, sprintf('q(x) = %.2f + %.2f*x', a, b), 'FontSize', 11);
text(0.1, 0.5, sprintf('Точка подвеса: x4 = %.4f', x4), 'FontSize', 11, 'FontWeight', 'bold');
text(0.1, 0.4, sprintf('Погрешность силы: %.2f%%', error_F), 'FontSize', 11);
text(0.1, 0.3, sprintf('Погрешность момента: %.2f%%', error_M), 'FontSize', 11);
    
function plot_lever_system(x1, x2, x3, x4, R, F2, F3)
    % Визуализация системы рычагов
    
    % Уровень 1 - точки крепления к крылу
    plot(x1, zeros(size(x1)), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k');
    for i = 1:length(x1)
        text(x1(i), -0.05, sprintf('R_{%d}=%.2f', i, R(i)), ...
             'HorizontalAlignment', 'center', 'FontSize', 8);
    end
    
    % Уровень 2
    plot(x2, 0.3*ones(size(x2)), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
    for j = 1:length(x2)
        text(x2(j), 0.35, sprintf('F2_{%d}=%.2f', j, F2(j)), ...
             'HorizontalAlignment', 'center', 'FontSize', 8);
    end
    
    % Уровень 3
    plot(x3, 0.6*ones(size(x3)), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
    for k = 1:length(x3)
        text(x3(k), 0.65, sprintf('F3_{%d}=%.2f', k, F3(k)), ...
             'HorizontalAlignment', 'center', 'FontSize', 8);
    end
    
    % Уровень 4 - точка подвеса груза
    plot(x4, 0.9, 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
    text(x4, 0.95, sprintf('Груз F\nx4=%.4f', x4), ...
         'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    
    % Соединительные линии
    for j = 1:4
        i1 = 2*j - 1;
        i2 = 2*j;
        plot([x1(i1), x2(j)], [0, 0.3], 'k--');
        plot([x1(i2), x2(j)], [0, 0.3], 'k--');
    end
    
    for k = 1:2
        j1 = 2*k - 1;
        j2 = 2*k;
        plot([x2(j1), x3(k)], [0.3, 0.6], 'b--');
        plot([x2(j2), x3(k)], [0.3, 0.6], 'b--');
    end
    
    plot([x3(1), x4], [0.6, 0.9], 'g--');
    plot([x3(2), x4], [0.6, 0.9], 'g--');
    
    xlabel('Координата x');
    ylabel('Уровень системы');
    ylim([-0.1, 1.0]);
    grid on;
end

