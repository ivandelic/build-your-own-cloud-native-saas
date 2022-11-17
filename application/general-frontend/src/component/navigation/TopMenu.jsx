import React, {Component} from "react";
import { Link } from 'react-router-dom';

class TopMenu extends Component {
    render() {
        return (
            <nav className="tesla-bar tesla-bar-top">
                <h1 className="tesla-headline tesla-pull-left">Cloud Native Stars Demo 2</h1>
                <ul className="tesla-menu tesla-menu-icon tesla-menu-icon-horizontal">
                    <li>
                        <Link to="/">
                            <span className="pi fa-fw pi-user"></span>
                        </Link>
                    </li>
                </ul>
            </nav>
        );
    }
}

export default TopMenu;