import React from 'react';
import ReactDOM from 'react-dom';
import { BrowserRouter, Route, Link } from 'react-router-dom'
import * as serviceWorker from './serviceWorker';
import SideMenu from './component/navigation/SideMenu';
import TopMenu from './component/navigation/TopMenu';
import Departments from './page/Departments';
import Branches from './page/Branches';
import Home from './page/Home';
import './theme/default/style.css';
import 'primereact/resources/primereact.min.css';
import 'primereact/resources/themes/nova-light/theme.css';
import 'primeflex/primeflex.css';
import 'primeicons/primeicons.css';

ReactDOM.render(
    <BrowserRouter>
        <div className="tesla max-height">
            <TopMenu></TopMenu>
            <SideMenu></SideMenu>
            <div className="tesla-wrapper max-height">
                <Route path="/" exact component={Home}></Route>
                <Route path="/departments" exact component={Departments}></Route>
                <Route path="/branches" exact component={Branches}></Route>
            </div>
        </div>
    </BrowserRouter>
    , document.getElementById('root'));

serviceWorker.unregister();