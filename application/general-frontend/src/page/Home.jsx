import React, { Component } from 'react';
import { Card } from 'primereact/card';

class Home extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <div className="grid p-justify-center p-align-center max-height">
                <Card title="Home" className="col-12 md:col-6 lg:col-6">
                    <div className="col-12">
                        Departments API URL: {process.env.REACT_APP_DEPARTMENT_API_URL}
                    </div>
                    <div className="col-12">
                        Branches API URL: {process.env.REACT_APP_BRANCH_API_URL}
                    </div>
                </Card>
            </div>
        );
    }
}
// 
export default Home;