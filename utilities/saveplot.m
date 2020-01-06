function saveplot(fig, fname)

% Usage: saveplot(fig, filename)
% Uses Imagemagick's convert utility for higher resolution PNGs if
% available
% Eg: saveplot(gcf, 'test');

    convert_fname='/usr/local/bin/convert.disabled';
    if nargin < 2
        fname = fig;
        fig = gcf;
    end
    
    set(fig, 'PaperPositionMode', 'auto');
    fname_eps=sprintf('%s.eps', fname);
    fname_png=sprintf('%s.png', fname);
    % Output to EPS
    print(gcf, fname_eps, '-depsc2', '-r0', '-painters');
    %%{
    % Output to PNG
    if exist(convert_fname, 'file')
        disp('Converting using Imagemagick');
        s=sprintf('%s -density 200 %s/%s %s/%s', convert_fname, pwd, fname_eps, pwd, fname_png);
        eval(['! ' s ';']);
        s=sprintf('%s -trim %s/%s %s/%s', convert_fname, pwd, fname_png, pwd, fname_png);
        eval(['! ' s ';']);
    else
        print(gcf, fname_png, '-dpng', '-opengl', '-r150');
    end
    disp(sprintf('Saving plot to %s .png and eps', fname));
    %%}
    disp(sprintf('Saving plot to %s .eps', fname));

end