# ECE 210 MATLAB & Signals "Forget Sheet"

This sheet summarizes key concepts and MATLAB functions relevant to ECE signal processing, aiming to provide a quick refresher on the essentials.

---

## 1. MATLAB Fundamentals

### 1.1. Basic Syntax & Environment
* **Variables:** Dynamically typed. `x = 5; y = 'hello'; z = [1 2; 3 4];`
* **Scripts (.m files):** Execute sequences of commands. Use `%%` to create runnable sections.
* **Functions (.m files):** `function output = funcName(input1, input2)` ... `end`. Must be saved in a file named `funcName.m`.
* **Workspace Hygiene:** Start scripts with `clc; clear; close all;`
    * `clc`: Clears Command Window.
    * `clear`: Removes variables from workspace.
    * `close all`: Closes all figure windows.
* **Help:** `help functionName`, `doc functionName`.

### 1.2. Matrix/Vector Operations
* **Creation:** `A = [1 2 3; 4 5 6]`, `v = 1:5` (1, 2, 3, 4, 5), `t = linspace(0, 1, 101)` (101 points from 0 to 1).
* **Indexing:** `A(row, col)`, `v(index)`, `A(:, 1)` (first column), `A(1, :)` (first row), `A(1:2, 1:2)` (submatrix), `v(end)` (last element). Indices start at 1.
* **Element-wise Ops:** `.*` (mult), `./` (right div), `.\` (left div), `.^` (power). **CRITICAL** for applying operations element-by-element to vectors/matrices (e.g., `sin(t) .* exp(-t)`).
* **Matrix Ops:** `*` (matrix mult), `/` (solve Ax=B via x=A\B), `\` (solve xA=B via x=B/A), `'` (transpose/complex conjugate transpose), `.'` (transpose only).
* **Useful Functions:** `size()`, `length()`, `numel()`, `sum()`, `mean()`, `max()`, `min()`, `find()`, `reshape()`, `zeros()`, `ones()`, `eye()`.

### 1.3. Plotting Essentials
* **Create Figure:** `figure;` or `figure(handle);`
* **2D Plotting:** `plot(x, y, 'LineSpec')` (e.g., `'b--o'` blue dashed line with circle markers).
* **Discrete Plotting:** `stem(n, x, 'filled')` (useful for discrete sequences).
* **Multiple Plots:**
    * Same Axes: `hold on; plot(x1, y1); plot(x2, y2); hold off;`
    * Subplots: `subplot(rows, cols, index); plot(...)` (arranges multiple axes in a grid).
    * Figure Title: `sgtitle('Overall Title');` (for subplots).
* **Labels & Appearance:**
    * `title('Plot Title')`, `xlabel('X-axis Label')`, `ylabel('Y-axis Label')`
    * `legend('Data 1', 'Data 2', 'Location', 'best')`
    * `xlim([xmin xmax])`, `ylim([ymin ymax])`
    * `xticks([...])`, `xticklabels({...})` (Customize axis ticks/labels). Use `pi` for radians.
    * `grid on;`, `axis equal;`, `axis tight;`
* **3D Plotting:** `surf(X, Y, Z)`, `mesh(X, Y, Z)` (often requires `meshgrid` first).
* **Image Display:** `imshow(img)` (handles scaling for image types), `imagesc(matrix)` (scales data to full colormap). `colorbar;`

---

## 2. Signal Representation & Generation

* **Continuous Time (Symbolic/Theory):** $x(t)$
* **Discrete Time (MATLAB):** Sampled signal $x[n] = x(nT_s)$. Represented as a vector in MATLAB.
* **Sampling Frequency:** $F_s$ (Hz). `Fs = 80e3;`
* **Sampling Period:** $T_s = 1/F_s$. `Ts = 1/Fs;`
* **Time Vector:** `t = (0:N-1)*Ts;` or `t = linspace(0, (N-1)*Ts, N);` where `N` is number of samples.
* **Signal Generation:**
    * Sinusoid: `A * cos(2*pi*f0*t + phi)`
    * Complex Exponential: `A * exp(1j * 2*pi*f0*t)` (Represents a single frequency $f_0$).
    * Noise: `noise_amp * randn(1, N)` (Gaussian white noise). `rand()` for uniform.
    * dB Conversion: `mag = 10^(dB/20);` (`db2mag = @(dB) 10.^(dB/20);`)

---

## 3. Fourier Analysis (DFT/FFT)

* **Concept:** Decompose signal into constituent frequencies. DFT operates on discrete, finite signals. FFT is a fast algorithm for DFT.
* **MATLAB:** `Y = fft(x);` (where `x` is the time-domain signal vector).
* **Output Interpretation:**
    * `Y` is complex-valued.
    * Length of `Y` is same as `x` (N).
    * Index 1: DC component (0 Hz).
    * Indices 2 to `floor(N/2)+1`: Positive frequencies (up to Nyquist).
    * Indices `floor(N/2)+2` to N: Negative frequencies (mirrored for real `x`).
* **Frequency Axis:**
    * Full (0 to $F_s$): `f_full = (0:N-1)*(Fs/N);`
    * Positive only (0 to $F_s/2$): `f_pos = (0:floor(N/2))*(Fs/N);` (adjust length slightly for odd N if needed)
    * Corresponding `Y` for positive: `Y_pos = Y(1:floor(N/2)+1);`
* **Centering DFT:** `Y_shifted = fftshift(Y);` -> Puts DC (0 Hz) in the center.
* **Centered Frequency Axis (-Fs/2 to Fs/2):** `f_shifted = (-N/2 : N/2-1)*(Fs/N);` or `f_shifted = linspace(-Fs/2, Fs/2 - Fs/N, N);`
* **Plotting Spectrum:**
    * Magnitude: `plot(f_shifted, abs(Y_shifted));`
    * Magnitude (dB): `plot(f_shifted, 20*log10(abs(Y_shifted)));`
    * Phase: `plot(f_shifted, rad2deg(unwrap(angle(Y_shifted))));` (`unwrap` corrects phase jumps).
* **Normalization:** `fft` output scales with signal length `N`. Sometimes normalized: `Y = fft(x)/N;` or `Y = fft(x)/sqrt(N);`. Be consistent.

---

## 4. Z-Transform & System Representation

* **Concept:** Transform for discrete-time signals/systems. Maps $x[n]$ to $X(z)$. Convolution in time $y[n]=x[n]*h[n]$ becomes multiplication in z-domain $Y(z)=X(z)H(z)$.
* **Transfer Function:** $H(z) = Y(z)/X(z)$. Describes the system.
* **Representations:**
    * **Polynomial:** $H(z) = \frac{B(z)}{A(z)} = \frac{b_0 + b_1 z^{-1} + ... + b_M z^{-M}}{1 + a_1 z^{-1} + ... + a_N z^{-N}}$.
        * MATLAB: Numerator `b = [b0, b1, ..., bM]`, Denominator `a = [1, a1, ..., aN]`. **Row vectors.**
    * **Pole-Zero-Gain:** $H(z) = k \frac{(z-z_1)(z-z_2)...}{(z-p_1)(z-p_2)...}$.
        * MATLAB: Zeros `z = [z1; z2; ...]`, Poles `p = [p1; p2; ...]`, Gain `k`. **Column vectors.** Preferred for numerical stability.
* **MATLAB Conversions (Signal Processing Toolbox):**
    * `[b, a] = zp2tf(z, p, k);` (Zero-Pole-Gain to Transfer Function)
    * `[z, p, k] = tf2zpk(b, a);` (Transfer Function to Zero-Pole-Gain)
    * `[sos, g] = zp2sos(z, p, k);` (Zero-Pole-Gain to Second-Order Sections)
    * `[sos, g] = tf2sos(b, a);` (Transfer Function to Second-Order Sections)
* **Poles & Zeros:** Roots of denominator $A(z)$ are poles ($p_i$). Roots of numerator $B(z)$ are zeros ($z_i$).
* **Stability:** For a causal LTI system, all poles must be *inside* the unit circle ($|p_i| < 1$).
* **Pole-Zero Plot:** `zplane(z, p);` or `zplane(b, a);`. Visualizes pole/zero locations relative to the unit circle.

---

## 5. Filter Analysis (Frequency Response)

* **Concept:** How a system $H(z)$ affects different frequencies. Evaluate $H(z)$ on the unit circle ($z = e^{j\omega}$).
* **MATLAB:** `freqz()` function (Signal Processing Toolbox).
    * `[H, w] = freqz(b, a, N_pts);` (Normalized freq $\omega$ from 0 to $\pi$)
    * `[H, f] = freqz(b, a, N_pts, Fs);` (Physical freq $f$ from 0 to $F_s/2$)
    * Can use `sos, g` instead of `b, a`: `[H, f] = freqz(sos, N_pts, Fs); H = H * g;` (Remember gain `g`!).
* **Output:** `H` is complex response, `w` or `f` is frequency vector.
* **Plotting:**
    * Magnitude (dB): `plot(f, 20*log10(abs(H)));`
    * Phase (degrees): `plot(f, rad2deg(unwrap(angle(H))));`
* **Key Features:** Passband, stopband, transition band, cutoff frequency, ripple, attenuation.

---

## 6. Filter Design

* **Goal:** Create a filter $H(z)$ meeting specific frequency response requirements.
* **Specifications:**
    * `Fs`: Sampling frequency.
    * `Rp`: Max passband ripple (dB).
    * `Rs`: Min stopband attenuation (dB).
    * `Wp`: Passband edge frequency(ies) (Hz).
    * `Ws`: Stopband edge frequency(ies) (Hz).
* **Steps (IIR Example - Elliptic):**
    1.  **Normalize Frequencies:** `fn = Fs/2; Wp_norm = Wp/fn; Ws_norm = Ws/fn;` (Frequencies must be between 0 and 1 for design functions).
    2.  **Estimate Order:** `[n, Wn_cutoff] = ellipord(Wp_norm, Ws_norm, Rp, Rs);` (Finds minimum order `n`).
    3.  **Design Filter:** `[b, a] = ellip(n, Rp, Rs, Wp_norm);` (Lowpass) or `[z, p, k] = ellip(n, Rp, Rs, Wp_norm);`. Use appropriate cutoff frequency argument (`Wp_norm` for lowpass/highpass, `Wn_cutoff` might differ for bandpass/stop). Check `doc ellip`.
    4.  **Convert to SOS (Recommended):** `[sos, g] = zp2sos(z, p, k);` (Or from `b, a`).
* **Filter Types:**
    * `butter`: Butterworth (maximally flat passband, monotonic). `buttord`.
    * `cheby1`: Chebyshev Type I (equiripple passband, monotonic stopband). `cheb1ord`.
    * `cheby2`: Chebyshev Type II (monotonic passband, equiripple stopband). `cheb2ord`.
    * `ellip`: Elliptic (Cauer) (equiripple passband and stopband, sharpest transition). `ellipord`.
* **FIR Filters:** Different design methods (e.g., `fir1`, `firls`, `firpm`). Often designed directly from coefficients `b` (`a=1`). Linear phase possible.

---

## 7. Filter Implementation

* **Applying Filter:** Process input signal `x` to get output `y`.
* **MATLAB:**
    * **Using `b, a` (TF form):** `y = filter(b, a, x);` (Can have numerical issues for high orders).
    * **Using `sos, g` (SOS form):** `y = sosfilt(sos, x); y = y * g;` **(Preferred for stability)**. Remember the overall gain `g`!
* **Initial Conditions/Transients:** Filtering introduces delay and transient effects at the beginning of the output signal.

---

## 8. Symbolic Math Toolbox

* **Purpose:** Analytical calculations, solving equations exactly, high-precision math.
* **Define Symbols:** `syms x y z a b c;` or `syms Vc(t) Vs(t) R C;` (for functions of time).
* **Create Expressions:** `expr = a*x^2 + b*x + c;`
* **Substitute Values:** `new_expr = subs(expr, [a, b, x], [1, 2, y]);` (Replace `a` with 1, `b` with 2, `x` with symbol `y`).
* **Solve Algebraic Equations:** `sol = solve(expr == 0, x);` or `sol = solve([eqn1, eqn2], [x, y]);` (Returns struct or symbolic vector).
* **Solve Differential Equations:** `sol_ode = dsolve(diff_eqn, y(t));` (e.g., `diff_eqn = diff(y,t,2) + y == 0`).
* **Simplify:** `simplified_expr = simplify(expr);` (Tries various algebraic rules). Other functions exist (`expand`, `factor`, `collect`).
* **High-Precision Evaluation:** `result = vpa(symbolic_expr, num_digits);` (e.g., `vpa(sym(pi), 100)`).
* **Convert to Numeric:** `numeric_val = double(symbolic_expr);` (If expression evaluates to a number).
* **Calculus:** `diff(expr, x)`, `int(expr, x, a, b)`.

---

## 9. Basic Image Processing Snippets (Context)

* **Reading:** `img = imread('image.png');`
* **Grayscale:** `img_gray = rgb2gray(img_rgb);`
* **Data Types:** `img_double = im2double(img_uint8);` (Scales 0-255 to 0-1). `img_uint8 = im2uint8(img_double);` (Scales 0-1 to 0-255).
* **Padding:** `img_padded = padarray(img, [pad_rows, pad_cols], pad_value, 'post');`
* **Block Processing:**
    * Extract: `blocks = im2col(img, [block_rows, block_cols], 'distinct');` (Blocks as columns).
    * Reconstruct: `img_reconstructed = col2im(blocks, [block_rows, block_cols], img_size, 'distinct');`
* **2D DCT:** `dct_block = dct2(block);`
* **Inverse 2D DCT:** `block = idct2(dct_block);`
* **Quality Metrics:** `psnr_val = psnr(img_reconstructed, img_original);`, `ssim_val = ssim(img_reconstructed, img_original);` (Require Image Processing Toolbox).

---

This sheet provides a starting point. Remember to consult the `doc` for specific function details and explore the capabilities of the Signal Processing, Symbolic Math, and Image Processing Toolboxes further as needed. Good luck!