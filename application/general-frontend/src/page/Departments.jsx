import React, { Component } from 'react';
import DepartmentDetail from '../component/department/DepartmentDetail'
import SimpleDataView from '../component/table/SimpleDataView'
import {DepartmentService} from '../service/DepartmentService'

class Departments extends Component {
    constructor(props) {
        super(props);
        this.state = {
            departments: [],
            department: {}
        }
        this.service = new DepartmentService();
    }

    componentWillMount() {
        this.loadData();
    }

    loadData() {
        this.service.list().then(departments => {
            this.setState({ 
                departments: departments,
                department: departments[0]
            });
        });
    }

    onDataItemNewEvent() {
        this.service.make().then(department => {
            this.setState({ 
                department: department,
            });
        });
    }

    onDataItemSaveEvent(item) {
        this.service.save(item).then(department => {
            this.service.list().then(departments => {
                this.setState({ 
                    departments: departments,
                    department: department
                });
            });
        });
    }

    onDataItemSelectEvent(item) {
        this.setState({ department: item });
    }

    onDataItemRemoveEvent(item) {
        this.service.delete(item.id).then(() => {
            this.loadData();
        });
    }

    render() {
        return (
            <div className="p-grid">
                <div className="p-col-12 p-md-6 p-lg-3">
                    <SimpleDataView 
                        dataItems={this.state.departments}
                        title="Departments"
                        selectedItem={this.state.department}
                        onDataItemSelect={this.onDataItemSelectEvent.bind(this)}
                        onDataItemNew={this.onDataItemNewEvent.bind(this)}
                    />
                </div>
                {!(Object.keys(this.state.departments).length === 0 && this.state.departments.constructor === Object) && 
                    <div className="p-col-12 p-md-6 p-lg-9">
                        <DepartmentDetail 
                            department={this.state.department}
                            onDataItemSave={this.onDataItemSaveEvent.bind(this)}
                            onDataItemRemove={this.onDataItemRemoveEvent.bind(this)}
                        />
                    </div>
                }
            </div>
        );
    }
}

export default Departments;