clear all
close all
%% Señal de prueba para la DFT
% Parámetros
f = 10; % Frecuencia del seno(Hz)
fs = 100; % Frecuencia de muestreo (Hz)
t = 0:1/fs:(1-1/fs); % Vector de tiempo de 1 seg, ajustado para tener 100 puntos
% Generar la secuencia de coseno
x = sen(2*pi*f*t);
% Graficar
plot(t, x);
xlabel('Tiempo (s)');
ylabel('Amplitud');
title(Sen de 10 Hz');
grid on;
m = length(x); %calculamos la longitud de la primera secuencia
%% Se configura el puerto serial y se abre el canal
delete(instrfind);
SerialPort='COM3'; %serial port
fincad = 'CR/LF';
baudios = 115200;
s = serial(SerialPort);
set(s,'BaudRate',baudios,'DataBits', 8, 'Parity', 'none','StopBits', 1,'FlowControl', 'none','Timeout',1);
set(s,'Terminator',fincad);
s.InputBufferSize = 2048;  % Tamaño del buffer en bytes
flushinput(s);
s.BytesAvailableFcnCount = m;
s.BytesAvailableFcnMode = 'byte';
%Se abre el puerto de comunicación
fopen(s);
fwrite(s, x, 'float');% Enviamos la senal creada al psoc
pause(5) %esperamos 5 segundos para darle tiempo al psoc de procesar todos los datos
          
%% Initializing variables - Primer grafico - Senal original
           datos = 0;
           flushinput(s);
           fwrite(s,'I')
           longitud = m+1;
           eco_med(1)=0;
           tiempo(1)=0;
           count = 1;
           k=0;
           while ~isequal(count,longitud)
            %%Re creating Serial port before timeout 
               k=k+1; 
               if k==longitud
                   fclose(s);
                   delete(s);
                   clear s;       
                   s = serial(SerialPort);
                   set(s,'Terminator',fincad);
                   set(s,'BaudRate',baudios,'Parity','none');
                   fopen(s)    
                   k=0;
               end
           datos(count) = str2double(fscanf(s));
           count = count+1;
           end
           
   figure
   plot(datos)
   ylabel('Amplitud');
   title('Senal Original Recibida del PSoC');
   grid on;
  
%% Initializing variables - Segundo grafico - Resultado de la DFT
           datos_dft = 0;
           flushinput(s);
           fwrite(s,'P')
           longitud = m+1;
           eco_med(1)=0;
           tiempo(1)=0;
           count = 1;
           k=0;
           while ~isequal(count,longitud)
            %%Re creating Serial port before timeout 
               k=k+1; 
               if k==longitud
                   fclose(s);
                   delete(s);
                   clear s;       
                   s = serial(SerialPort);
                   set(s,'Terminator',fincad);
                   set(s,'BaudRate',baudios,'Parity','none');
                   fopen(s)    
                   k=0;
               end
           datos_dft(count) = str2double(fscanf(s));
           count = count+1;
           end
            
   figure
   stem(datos_dft)
  
%% realizamos la fft en matlab para comparar con el resultado del PSoC
x_dft = fft(x);
% Obtener el número de puntos en la dft de
N = length(x_dft);
modulo_dft = abs(x_dft(1:N/2)/N); %la dft da como resultado un numero complejo, para ver las componentes en frecuencia debemos de calcular su modulo
% Construir el vector de frecuencias normalizado
frequencies_normalized = fs.*(0:(N/2)-1)./N; %Esta expresión genera un vector de frecuencias que se utilizan para etiquetar el eje
%x cuando se grafica el espectro de frecuencia de la señal.
% Visualizar el espectro en frecuencia de realizado con matlab y con el PSoC
figure
subplot(3,1,1)
plot(x)
title('Senal Original');
ylabel('Amplitud');
subplot(3,1,2)
plot(frequencies_normalized, modulo_dft);
title('Espectro en Frecuencia Normalizado del MATLAB');
xlabel('Frecuencia Normalizada');
ylabel('Magnitud');
subplot(3,1,3)
plot(datos_dft(1:N/2)/N); %Recordar que solo se necesita ver la primera mitad del resultado de la DFT
title('Espectro en Frecuencia Normalizado del PSoC');
xlabel('Frecuencia Normalizada');
ylabel('Magnitud');
%% Clean up the serial port
flushinput(s);
fclose(s);
delete(s);
clear s;
disp("Puerto serial cerrado")
