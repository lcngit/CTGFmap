%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function CTGFmap_Classes_Scatter_Chart(ChartData, ClassIds, n_dimen, ...
    azmt, elev, chartit, ChartAxis, ChartColors, ChartLeg, ...
    chartfname, n_pfit)

if n_dimen ~= 2 && n_dimen ~= 3
    error('Error! Invalid dimension, it should be 2 or 3!');
end
n_vec = numel(ClassIds);
[nr_y, nc_y] = size(ChartData);
if n_vec ~= nr_y
    error('Error! Invalid number of points coordinates');
end
if n_dimen > nc_y
    error('Error! Number of coordinate dimension less than chart dimension!');
end
n_cls = numel(unique(ClassIds));

dispmsg = ['---- Display chart for ', num2str(n_vec), ...
    ' points, dimensions: ', num2str(n_dimen)];
if n_dimen == 3
    dispmsg = strcat(dispmsg, ', azimuth: ', num2str(azmt), ...
        ', vertical elevation: ', num2str(elev));
end
dispmsg = strcat(dispmsg, ' ----');
disp(dispmsg);

C = zeros(n_vec, 3);
for i = 1:n_vec
    C(i,:) = ChartColors(ClassIds(i),:);
end
hold on
if n_dimen == 2
    scatter(ChartData(:,1), ChartData(:,2), 10, C, '+');
else
    scatter3(ChartData(:,1), ChartData(:,2), ChartData(:,3), 10, C, '+');
    view(azmt, elev);
end

colormap(ChartColors);
if n_cls > 1
    cb = colorbar;
    caxis([-0.5 (n_cls - 0.5)]);
    set(cb,'ytick',0:(n_cls-1),'yticklabel', ChartLeg);
else
    colorbar('off');
    chartit = strcat(chartit, {' - class: '}, cellstr(ChartLeg));
end

if n_dimen == 3
    chartit = [chartit, ' (Azimuth:', num2str(azmt), ...
        ', Elevation:', num2str(elev), ')'];
end
xlabel(ChartAxis{1});
ylabel(ChartAxis{2});
if n_dimen == 3
    zlabel(ChartAxis{3});
end

title(chartit);

if n_dimen == 2 && n_pfit > 0
    [Xactual, IndData] = sort(ChartData(:, 1));
    Yactual = ChartData(IndData, 2);
    Pcoeff = polyfit(Xactual, Yactual, n_pfit);
    disp('    Polynomial approximation coefficients:');
    tplt = '';
    for i = 1:(n_pfit + 1)
        deg = n_pfit-i+1;
        disp(['        Coefficient of x^',num2str(deg), ...
            ': ', num2str(Pcoeff(i))]);
        if i > 1
            tplt = strcat(tplt,'+');
        end
        if deg ~= 0
            tplt = strcat(tplt,num2str(Pcoeff(i)),'x^',num2str(deg));
        else
             tplt = strcat(tplt,num2str(Pcoeff(i)));
       end
    end
    Yfit = polyval(Pcoeff, Xactual);
    plot(Xactual, Yfit, 'Color', 'black', 'LineStyle', '--');
    maxx = max(Xactual);
    minx = min(Xactual);
    xplt = minx + ((maxx - minx) * 0.3);
    maxy = max(Yactual);
    miny = min(Yactual);
    yplt = miny + ((maxy - miny) * 0.05);
    text(xplt, yplt, tplt);
end

grid on
hold off
figfname = strcat('ScatterChart', num2str(n_dimen), 'D_', chartfname);
if n_dimen == 3
    figfname = strcat(figfname, '_Az', num2str(azmt), '_Ev', num2str(elev));
end
disp(['    Chart saved on: ', figfname, '.pdf']);
print(figfname,'-dpdf', '-r300');
disp(['    Figure saved on: ', figfname, '.fig']);
savefig(figfname);
close all

end