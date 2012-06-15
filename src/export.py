# this writes jflowview outputs
# #
# hardy_db=> select * from v_contrib_by_month_k5 limit 10
# ;
#  lang | yyyy | mm | article_x | article_y | contrib_x | contrib_y | contrib_n 
# ------+------+----+-----------+-----------+-----------+-----------+-----------
#  ca   | 2006 |  1 |        -5 |        40 |         0 |        45 |         1
#  ca   | 2006 |  1 |         0 |        40 |        -5 |        40 |        49
#  ca   | 2006 |  1 |         0 |        40 |        -0 |        40 |         6
#  ca   | 2006 |  1 |         5 |        50 |         5 |        50 |         1
#  ca   | 2006 |  1 |        20 |        50 |        10 |        50 |         3
#  ca   | 2006 |  1 |       125 |        10 |       -80 |        45 |         2
#  ca   | 2006 |  1 |       125 |        40 |        -5 |        40 |         1
#  cs   | 2006 |  1 |        -0 |        50 |        15 |        50 |         1
#  cs   | 2006 |  1 |        15 |        50 |        15 |        50 |         5
#  cs   | 2006 |  1 |        20 |        45 |        15 |        50 |         1
# (10 rows)
import csv
import os
import psycopg2
import psycopg2.extras

filter_contrib_n = 1
cluster_k = 10.0

def cluster(x, y):
    return (x, y)
    # return (cluster_k*round(x/cluster_k), cluster_k*round(y/cluster_k))

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
                sql = '''SELECT * FROM contrib_by_month_k5 WHERE lang = '%s' AND yyyy = %d AND mm = %d AND contrib_n >= %d''' % (lang, yr, month, filter_contrib_n)
                cur.execute(sql)
                for row in cur.fetchall():
                    row['contrib_n'] = int(row['contrib_n'])
                    if row['contrib_n'] < filter_contrib_n:
                        continue
                    
                    row['yyyy'] = int(row['yyyy'])
                    row['mm'] = int(row['mm'])
                    row['article_x'] = float(row['article_x'])
                    row['article_y'] = float(row['article_y'])
                    row['contrib_x'] = float(row['contrib_x'])
                    row['contrib_y'] = float(row['contrib_y'])
                    # print lang, yr, month
                    # print row['lang'], row['yyyy'], row['mm']
                    if row['lang'] == lang and row['yyyy'] == yr and row['mm'] == month:
                        xy_dst = cluster(row['article_x'], row['article_y'])
                        xy_src = cluster(row['contrib_x'], row['contrib_y'])

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

