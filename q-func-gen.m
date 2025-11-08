% Параметры
L = 1; % Длина крыла
n_points = 8; % Количество точек
x_points = linspace(0, L, n_points);

% Создание массива q с различными законами изменения
q_points = zeros(1, n_points);

% 1. Линейный закон со случайными коэффициентами (первые 3 точки)
a_linear = rand() * 2; % случайный коэффициент от 0 до 2
b_linear = rand() * 3; % случайный коэффициент от 0 до 3
q_points(1:3) = a_linear + b_linear * x_points(1:3);

% 2. Параболический закон (следующие 3 точки)
a_parab = rand() * 1;
b_parab = rand() * 2;
c_parab = rand() * 3;
q_points(4:6) = a_parab + b_parab * x_points(4:6) + c_parab * x_points(4:6).^2;

% 3. Гиперболический закон (последние 2 точки)
% q(x) = A/(x + C) + B, чтобы избежать деления на 0
A_hyper = rand() * 2 + 0.5;
B_hyper = rand() * 1;
C_hyper = 0.1; % небольшое смещение
q_points(7:8) = A_hyper ./ (x_points(7:8) + C_hyper) + B_hyper;

% Нормализуем, чтобы значения были в разумном диапазоне
q_points = q_points / max(q_points) * 5; % масштабируем до максимума 5

% Визуализация
figure('Position', [100, 100, 800, 600]);

subplot(2,1,1);
plot(x_points, q_points, 'ro-', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'r');
xlabel('Координата x');
ylabel('Нагрузка q(x)');
title('Массив точек нагрузки с различными законами');
grid on;

% Подписи точек
for i = 1:n_points
    text(x_points(i), q_points(i)+0.1, sprintf('q_%d=%.2f', i, q_points(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 9);
end

% Показываем зоны разных законов
hold on;
y_lim = ylim;
fill([0 x_points(3) x_points(3) 0], [y_lim(1) y_lim(1) y_lim(2) y_lim(2)], 'g', 'FaceAlpha', 0.1);
fill([x_points(3) x_points(6) x_points(6) x_points(3)], [y_lim(1) y_lim(1) y_lim(2) y_lim(2)], 'b', 'FaceAlpha', 0.1);
fill([x_points(6) L L x_points(6)], [y_lim(1) y_lim(1) y_lim(2) y_lim(2)], 'm', 'FaceAlpha', 0.1);

text(x_points(2), y_lim(2)-0.3, 'Линейный', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
text(x_points(5), y_lim(2)-0.3, 'Параболический', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
text(x_points(7), y_lim(2)-0.3, 'Гиперболический', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

% Информация о параметрах
subplot(2,1,2);
axis off;
text(0.1, 0.9, 'Параметры законов:', 'FontSize', 12, 'FontWeight', 'bold');
text(0.1, 0.8, sprintf('Линейный: q(x) = %.2f + %.2f*x', a_linear, b_linear), 'FontSize', 10);
text(0.1, 0.7, sprintf('Параболический: q(x) = %.2f + %.2f*x + %.2f*x^2', a_parab, b_parab, c_parab), 'FontSize', 10);
text(0.1, 0.6, sprintf('Гиперболический: q(x) = %.2f/(x+%.1f) + %.2f', A_hyper, C_hyper, B_hyper), 'FontSize', 10);
text(0.1, 0.5, sprintf('Диапазон значений: [%.2f, %.2f]', min(q_points), max(q_points)), 'FontSize', 10);

fprintf('Создан массив q_points с %d точками:\n', n_points);
for i = 1:n_points
    fprintf('q_points(%d) = %.4f\n', i, q_points(i));
end
