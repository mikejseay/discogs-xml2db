"""
Author: Mohit Mayank
Idea: Plot Game of Thrones network using Visdcc in Dash.
"""

# imports
import numpy as np
import pandas as pd
import dash
import visdcc
from dash import dcc, html
from dash.dependencies import Input, Output, State

genreSizes = pd.read_csv('C:/Users/mikejseay/Documents/Code/discogs-xml2db/output_csv/genreFrequencies.csv')
genreSizes.set_index('genre', inplace=True)
genreSizes.rename(columns={'cnt': 'size'}, inplace=True)

genreWeights = pd.read_csv('C:/Users/mikejseay/Documents/Code/discogs-xml2db/output_csv/genreCoOccurences.csv')
genreWeights.rename(columns={'cnt': 'weight'}, inplace=True)

normFactor = []
for g1, g2 in genreWeights[['g1', 'g2']].values:
    normFactor.append(np.sqrt(genreSizes.loc[g1, 'size'] * genreSizes.loc[g2, 'size']))

genreWeights['normFactor'] = normFactor
genreWeights['normWeight'] = genreWeights['weight'] / genreWeights['normFactor']
genreWeights['normWeight'] = genreWeights['normWeight'] / genreWeights['normWeight'].max()

# sparsify weights

genreWeightsSparse = genreWeights.loc[genreWeights['normWeight'] > .1, :]

sizeNorm =  7 / genreSizes['size'].mean()
weightNorm = 2 / genreWeights['normWeight'].mean()

# load data
df = genreWeights.loc[genreWeights['normWeight'] > .1, :]
node_list = list(set(df['g1'].unique().tolist() + df['g2'].unique().tolist()))
nodes = [{'id': node_name, 'label': node_name, 'shape': 'dot', 'size': size * sizeNorm } for node_name, size in list(genreSizes.to_records())]
# create edges from df
edges = []
for row in df.to_dict(orient='records'):
    source, target = row['g1'], row['g2']
    edges.append({
        'id': source + "__" + target,
        'from': source,
        'to': target,
        'width': row['normWeight'] * weightNorm,
    })

# create app
app = dash.Dash()


# define layout
app.layout = html.Div([
      visdcc.Network(id = 'net', 
                     data = {'nodes': nodes, 'edges': edges},
                     options = dict(height= '600px', width= '100%')),
])

# define callback
@app.callback(
    Output('net', 'options'),
    [Input('color', 'value')])
def myfun(x):
    return {'nodes':{'color': x}}

# define main calling
if __name__ == '__main__':
    app.run_server(debug=True)