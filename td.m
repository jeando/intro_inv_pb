function f()
close all;
    x=imread('peppers.png');
    x=double(x(:,:,1));

        m=zeros(size(x));
        m_size=15;
        
        
        
        std=2;%a changer pour la derniere question
        
        
        
        m(1:m_size,1:m_size)=fspecial('gaussian',m_size,std);
        s = floor(-(size(m(1:m_size,1:m_size))-1)/2);
        m=circshift(m,s);
        conv=x;
        imshow(x/255);
        figure;
        %for k=1:80
         %   conv=ifft2(fft2(conv).*fft2(m));
          %  pause(0.0001);imshow(conv/255);
       % end
        figure;imshow(conv/255);
        
        
    sigma_b = 7;
    b=sigma_b * randn(size(x));
    y=ifft2(fft2(x).*fft2(m))+b;
   % function calc_x_chapeau(x_chapeau,m,y,lambda);
    lambda=0.25;
   
    x_chapeau = ifft2(conj(fft2(m)).*fft2(y)./((abs(fft2(m)).^2+lambda)));
        figure;imshow(y/255);
        figure;imshow(x_chapeau/255);
        colorbar;
        figure;imagesc(x_chapeau/255);
        colorbar;
        figure;imshow(x_chapeau,[min(x_chapeau(:)) max(x_chapeau(:))]);
        colorbar;
        %figure;imshow(histeq(x_chapeau/255));
        %minx = min(min(x_chapeau));
        %maxx = max(max(x_chapeau));
        %figure;imshow(imadjust(x_chapeau)/255);
        %figure;imshow(b/255);
        %imshow(x/255);
    
        
        lambda=30;
        
        
        
        
        
        %tester differentes valeurs
        alpha=0.01;%0.01
        
        
        
        
        
        max_nbr_iteration = 50;
        negligible_variation = 10^-6;
        
        M=fft2(m);
        Y=fft2(y);
        epsilon=1;
        epsilon2=epsilon^2;
        
        
        s=y;% s -> x_0
        iteration = 0;
        dim = size(s);
        energie = 0;
        for u = 1 : dim(1)
            for v = 1 : dim(2)
                energie = energie + sqrt(s(u,v)^2+epsilon2)-epsilon;
            end
        end
        %disp(size(energie));
        %disp(norm(ifft2(Y-M.*fft2(s)))^2)
        energie = energie * lambda + norm(ifft2(Y-M.*fft2(s)))^2;
        disp(energie);
        while(iteration<max_nbr_iteration)
            [gx, gy] = gradient(s);
            norm_grad_x = sqrt(gx.^2 + gy.^2);

            phi_prim = norm_grad_x./sqrt(norm_grad_x.^2+epsilon2);

            c_s=phi_prim./(2*norm_grad_x);


            [div_1, null] = gradient(c_s.*gx);
            [null, div_2] = gradient(c_s.*gy);

            div = div_1+div_2;
            grad_E = 2*ifft2(M.*(M.*fft2(s)-Y)) -lambda*div;
            
            s2 = s - alpha * grad_E;
            
            
			energie = 0;
			for u = 1 : dim(1)
				for v = 1 : dim(2)
					energie = energie + sqrt(s(u,v)^2+epsilon2)-epsilon;
				end
			end
			energie = energie * lambda + norm(ifft2(Y-M.*fft2(s)))^2;
            disp(energie);
            if(norm(s2-s)<epsilon)
                s=s2;
                break;
            end
            iteration = iteration + 1;
            s=s2;
        end
        fig_s = figure('Name', 'S O');
        fig_c = figure('Name', 'C O');
        set(fig_s, 'Name', ['S ' int2str(iteration)])
        figure(fig_s)
        imagesc(s); axis image off
        colormap(gray); colorbar
        set(fig_c, 'Name', ['C ' int2str(iteration)])
        figure(fig_c)
        imagesc(c_s); axis image off
        colormap(gray); colorbar
        drawnow
        
        figure('Name', 'fft(y)');imagesc(log(abs(fftshift(Y))));colorbar;
        figure('Name', 'fft(s)');imagesc(log(abs(fftshift(fft2(s)))));colorbar;
        figure('Name', 'fft(x)');imagesc(log(abs(fftshift(fft2(x)))));colorbar;
        
end