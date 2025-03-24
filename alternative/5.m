%% Problem 1: Square Wave Approximation
t = linspace(-pi, pi, 1000);
s = zeros(size(t));

figure;
hold on;
for n = 0:50
    a_n = 2*n + 1;
    component = sin(a_n * t) / a_n;
    s = s + component;
    plot(t, component, 'Color', [0.8 0.8 0.8 0.1]);  % Light gray components
end
plot(t, s, 'b', 'LineWidth', 1.5);
title('Square Wave Approximation with Components');
xlabel('t');
ylabel('Amplitude');
xlim([-pi, pi]);
ylim([-1.5, 1.5]);
xticks(-pi:pi/2:pi);
xticklabels({'-\pi', '-\pi/2', '0', '\pi/2', '\pi'});
grid on;

%% Problem 2: Subplots
figure;
subplot(2,1,1);
plot(t, s, 'b');
title('Approximation');
xlim([-pi, pi]);
ylim([-1.5, 1.5]);
grid on;

subplot(2,1,2);
hold on;
for n = 0:50
    a_n = 2*n + 1;
    component = sin(a_n * t) / a_n;
    plot(t, component, 'Color', [0.8 0.8 0.8 0.1]);
end
title('Components');
xlim([-pi, pi]);
ylim([-1.5, 1.5]);
sgtitle('Square Wave Approximation and Components');
grid on;

%% Problem 3: Surface Plot
[x, y] = meshgrid(linspace(-2*pi, 2*pi, 100));
z = x .* sin(x) - y .* cos(y);

figure;
surf(x, y, z);
shading interp;
title('Surface: z = x sin(x) - y cos(y)');
xlabel('x');
ylabel('y');
zlabel('z');
colorbar;