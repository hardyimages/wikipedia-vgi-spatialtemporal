# this writes jflowview outputs
#
#   year month lang article_id article_x article_y contrib_x contrib_y contrib_n
# 1 2004    10   no         65      11.4      48.8      11.8      60.7         1
# 2 2004    10   no        140       5.6      58.7       5.7      58.7         4
# 3 2004    10   no        173     -53.0     -10.6      10.4      59.3         1
# 4 2004    10   no        185      14.4      67.3      11.8      60.7         1
# 5 2004    10   no        185      14.4      67.3      13.7      66.9         2
# 6 2004    10   no        260      10.2      59.7      10.8      59.9         1
import csv
import os
import psycopg2
import psycopg2.extras

filter_contrib_n = 0
cluster_k = 1

conn = psycopg2.connect("host=127.0.0.1 dbname=hardy_db user=hardy password=eEPerem65")
print conn
#cur = conn.cursor()
cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

for lang in ["ca", "cs", "da", "de", "en", "eo", "es", "fi", "fr", "is", "it", "ja", "nl", "no", "pl", "pt", "ru", "sk", "sv", "tr", "zh"]:
    os.mkdir('data/%s' % (lang))

    for yr in range(2002,2008+1):
        for month in range(1,12+1):
            try:
                print 'processing', lang, yr, month
                nodes = {}
                edges = []
                cur.execute('''SELECT * FROM contrib_by_month WHERE lang = '%s' AND yyyy = %d AND mm = %d''' % (lang, yr, month))
                for row in cur.fetchall():
                    row['yyyy'] = int(row['yyyy'])
                    row['mm'] = int(row['mm'])
                    row['contrib_n'] = int(row['contrib_n'])
                    row['article_id'] = int(row['article_id'])
                    row['article_x'] = float(row['article_x'])
                    row['article_y'] = float(row['article_y'])
                    row['contrib_x'] = float(row['contrib_x'])
                    row['contrib_y'] = float(row['contrib_y'])
                    # print lang, yr, month
                    # print row['lang'], row['yyyy'], row['mm']
                    if row['lang'] == lang and row['yyyy'] == yr and row['mm'] == month:
                        xy_dst = (row['article_x'], row['article_y'])
                        xy_src = (row['contrib_x'], row['contrib_y'])

                        if row['contrib_n'] >= filter_contrib_n:
                            for xy in [xy_dst, xy_src]:
                                if xy not in nodes:
                                    nodes[xy] = 'N%d' % (len(nodes)+1)

                            edges.append([nodes[xy_src], nodes[xy_dst], row['contrib_n']])
                    else:
                        break

                fn = 'data/%s/%04d%02d_nodes.csv' % (lang, yr, month)
                f = csv.writer(open(fn, 'w'))
                f.writerow(['Code', 'Name', 'Lon', 'Lat'])
                for k in nodes:
                    f.writerow([nodes[k], nodes[k], k[0], k[1]])
                f = None
            
                fn = 'data/%s/%04d%02d_edges.csv' % (lang, yr, month)
                f = csv.writer(open(fn, 'w'))
                f.writerow(['Origin', 'Dest', 'Contrib'])
                for e in edges:
                    f.writerow(e)
                f = None
                
                fn = 'data/%s/%04d%02d.jfmv' % (lang, yr, month)
                print >>open(fn, 'w'), '''
view=flowmap

data=csv
data.csv.nodes.src=%04d%02d_nodes.csv
data.csv.flows.src=%04d%02d_edges.csv


data.attrs.node.id=Code
data.attrs.node.label=Name
data.attrs.node.lat=Lat
data.attrs.node.lon=Lon
data.attrs.flow.origin=Origin
data.attrs.flow.dest=Dest

data.attrs.flow.weight.csvList=Contrib


map=shapefile
map.shapefile.src=../../countries.shp
map.projection=Mercator

                ''' % (yr, month, yr, month)
            except IOError, e:
                pass

