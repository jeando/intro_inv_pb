function td2()
%clean session
    close all;
    clear all;

%load image
    img=imread('peppers.png');
    img=double(img(:,:,1));
    disp(size(img));

	imwrite(img/255,strcat('test_ini.png'));

%add noise
    sigma_b = 7;
    b=sigma_b * randn(size(img));
    img = img + b;

%in order to test different parameters
    tab_alpha = [100];
    tab_w = [21];
    tab_k = [5,10,20,40,80];
    
     n=11;     %  mask size around pixel

%    w=21;%5*n % searching window
%    k=10;     % number of patches
%    alpha=100;

	img2=img;
	imwrite(img2/255,strcat('test_noise.png'));
    
    for alpha = tab_alpha
        for w = tab_w
            for k = tab_k

    			img2=img;%new image
				%for each pixel we compute the new value with the function similar_patches
    			for x=n:size(img,2)-n
        			for y=n:size(img,1)-n
            			img2(y,x) = similar_patches(img, n, w,x,y,k,alpha);
        			end
        			disp(x);
    			end

				%draw the noisy image and the new image
			    figure;imagesc(img/255);
			    colorbar;
			    colormap(gray);
			    figure;imagesc(img2/255);
			    colorbar;
			    colormap(gray);

				%save the image
				imwrite(img2/255,strcat('w=',int2str(w),'_k=',int2str(k),'alpha=',int2str(alpha),'.png'));
        	end
    	end
	end

	%extract a patch n by n around the pixel (x,y)
	%assert than we can do this
    function pref = patch_extract(img, n,x,y)
        pref = img((y-(n-1)/2):(y+(n-1)/2),( x-(n-1)/2):(x+(n-1)/2));
    end

    %return the new value of the pixel (x,y).
    function [ val] = similar_patches(img, n, w,x,y,k,alpha)
        n_moins_un_sur_deux = (n-1)/2;%to compute this term only once.

		%this is the reference patch
        pref = img((y-n_moins_un_sur_deux):(y+n_moins_un_sur_deux),( x-n_moins_un_sur_deux):(x+n_moins_un_sur_deux));
       
	   %we check the border condition for the searching windows	
        row_begin = max(y-(w-1)/2,1+n_moins_un_sur_deux);
        row_end = min(y+(w-1)/2,size(img,1)-n_moins_un_sur_deux);
        
        n_rows = row_end - row_begin+1;
        
        col_begin = max(x-(w-1)/2,1+n_moins_un_sur_deux);
        col_end =  min(x+(w-1)/2,size(img,2)-n_moins_un_sur_deux);
        
       
		%for each pixel of the searching window we extract a patch n by n and we compute the distance with the reference patch
		%and we save it with the location (col,row) of this pixel.
        all_norm = zeros((col_end-col_begin+1)*n_rows,3);
        for col = col_begin : col_end
            ccols = col - col_begin;
            ccols_x_n_row = ccols*n_rows;
            for row = row_begin : row_end
                rrows = row - row_begin;
                all_norm(ccols_x_n_row+rrows+1,:)=[sum(sum((pref-img((row-n_moins_un_sur_deux):(row+n_moins_un_sur_deux),( col-n_moins_un_sur_deux):(col+n_moins_un_sur_deux))).^2)),row,col];
            end
        end

		%we sort the distances and for the k lower distances we compute the weight we will give to the corresponding patch
        [sorted_value, indice] = sort(all_norm(:,1));
        row = all_norm(indice,2);
        col = all_norm(indice,3);
        tmp2 = zeros(n,n);
        un_sur_alpha_nn = 1/(alpha * n * n);
        weight = exp(-sorted_value(1:k)*un_sur_alpha_nn);
		%we have to normalize the weight
        total_weight_inv = 1/sum(weight);
        weight=weight*total_weight_inv;
		%it would be better if we compute the weighted-sum only for the central pixel
        for i = 1 : k
            tmp2 = tmp2 + patch_extract(img,n,col(i),row(i))*weight(i);
        end
        val = tmp2(n_moins_un_sur_deux+1,n_moins_un_sur_deux+1);
    end
end


