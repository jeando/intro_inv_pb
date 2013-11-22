function td2()
    close all;
    clear all;
    img=imread('peppers.png');
    img=double(img(:,:,1));
    disp(size(img));

imwrite(img/255,strcat('test_ini.png'));
    sigma_b = 7;
    b=sigma_b * randn(size(img));
    img = img + b;

    tab_alpha = [100];
    tab_w = [21];
    tab_k = [5,10,20,40,80];
    
    n=11;%taille du mask autour du pixel
    w=21;%5*n % taille de la fenetre de recherche
    k=10;%nombre de patch que l'on garde
    
    alpha=100;
img2=img;
imwrite(img2/255,strcat('test_______w=',int2str(w),'_k=',int2str(k),'alpha=',int2str(alpha),'.png'));
    
    for alpha = tab_alpha
        for w = tab_w
            for k = tab_k
    img2=img;%new image
    for x=n:size(img,2)-n
        for y=n:size(img,1)-n
            img2(y,x) = similar_patches(img, n, w,x,y,k,alpha);
        end
        disp(x);
    end

    figure;imagesc(img/255);
    colorbar;
    colormap(gray);
    figure;imagesc(img2/255);
    colorbar;
    colormap(gray);
imwrite(img2/255,strcat('w=',int2str(w),'_k=',int2str(k),'alpha=',int2str(alpha),'.png'));
        end
    end
end

    function pref = patch_extract(img, n,x,y)
        pref = img((y-(n-1)/2):(y+(n-1)/2),( x-(n-1)/2):(x+(n-1)/2));
    end

    %retourne la nouvelle valeur du pixel (x,y).
    function [ val] = similar_patches(img, n, w,x,y,k,alpha)
        n_moins_un_sur_deux = (n-1)/2;
        pref = img((y-n_moins_un_sur_deux):(y+(n-1)/2),( x-n_moins_un_sur_deux):(x+n_moins_un_sur_deux));
        
        row_begin = max(y-(w-1)/2,1+n_moins_un_sur_deux);
        row_end = min(y+(w-1)/2,size(img,1)-n_moins_un_sur_deux);
        
       % n_rows = row_end - row_begin;
        n_rows = row_end - row_begin+1;%a voir
        
        col_begin = max(x-(w-1)/2,1+n_moins_un_sur_deux);
        col_end =  min(x+(w-1)/2,size(img,2)-n_moins_un_sur_deux);
        
        
        all_norm = zeros((col_end-col_begin+1)*n_rows,3);%+1 a voir
        
        for col = col_begin : col_end
            ccols = col - col_begin;
            ccols_x_n_row = ccols*n_rows;
            for row = row_begin : row_end
                rrows = row - row_begin;
                all_norm(ccols_x_n_row+rrows+1,:)=[sum(sum((pref-img((row-n_moins_un_sur_deux):(row+n_moins_un_sur_deux),( col-n_moins_un_sur_deux):(col+n_moins_un_sur_deux))).^2)),row,col];
            end
        end
        [sorted_value, indice] = sort(all_norm(:,1));
        row = all_norm(indice,2);
        col = all_norm(indice,3);
        tmp2 = zeros(n,n);
        un_sur_alpha_nn = 1/(alpha * n * n);
        weight = exp(-sorted_value(1:k)*un_sur_alpha_nn);
        total_weight_inv = 1/sum(weight);
        weight=weight*total_weight_inv;
        for i = 1 : k
            tmp2 = tmp2 + patch_extract(img,n,col(i),row(i))*weight(i);
        end
        val = tmp2(n_moins_un_sur_deux+1,n_moins_un_sur_deux+1);
    end
end
