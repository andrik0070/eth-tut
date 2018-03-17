
import 'babel-polyfill';
import React from 'react';
import ReactDOM from 'react-dom';
import App from  './components/App.jsx';

require('popper.js');
require('bootstrap-loader');


ReactDOM.render(<App />, document.getElementById('root'));

