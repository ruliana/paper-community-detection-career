#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Nov  5 10:06:40 2017

@author: ronie
"""

import networkx as nx

graph = nx.read_pajek("./data/edge-list-ocupacoes3.net")

print(nx.degree_assortativity_coefficient(graph))