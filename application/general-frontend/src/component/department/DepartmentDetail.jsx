import React, { Component } from 'react'
import {Button} from 'primereact/button';
import {Card} from 'primereact/card';
import {InputText} from 'primereact/inputtext';
import PropTypes from 'prop-types';
import { Binding } from '../../utils/Util'

class DepartmentDetail extends Component {
    constructor(props) {
        super(props);
        this.state = {
            department: this.props.department
        }
    }

    static getDerivedStateFromProps(props, state) {
        if (props.department !== state.department) {
            return {
                department: props.department
            };
        }
        return {};
    }

    binding(object, node, e) {
        this.setState({
            department: Binding.updateByString.bind(null, object, node, e.target.value).call()
        });
    }

    render() {
        return (
            <Card title="Department Details" className="wc">
                <div className="p-grid">
                    <div className="p-col-12 p-md-6">
                        <h2>ID</h2>
                        <InputText
                            id="departmentId"
                            type="text"
                            value={this.state.department.id || ''}
                            onChange={this.binding.bind(this, this.state.department, 'id')}
                        />
                    </div>
                    <div className="p-col-12 p-md-6"></div>
                    <div className="p-col-12">
                        <hr></hr>
                    </div>
                    <div className="p-col-12 p-md-6">
                        <h2>Name</h2>
                        <InputText
                            id="departmentName"
                            type="text"
                            value={this.state.department.name || ''}
                            onChange={this.binding.bind(this, this.state.department, 'name')}
                        />
                    </div>
                    <div className="p-col-12 p-md-6">
                        <h2>Code</h2>
                        <InputText
                            id="departmentCode"
                            type="text"
                            value={this.state.department.code || ''}
                            onChange={this.binding.bind(this, this.state.department, 'code')}
                        />
                    </div>
                    <div className="p-col-12">
                        <hr></hr>
                    </div>
                    <div className="p-col-12">
                        <h2>Description</h2>
                        <InputText
                            id="departmentDescription"
                            type="text"
                            value={this.state.department.description || ''}
                            onChange={this.binding.bind(this, this.state.department, 'description')}
                        />
                    </div>
                    <div className="wc-button-container p-col-12">
                        {!!this.state.department.id && 
                            <Button label="Delete" className="p-button-raised" icon="pi pi-minus" onClick={this.props.onDataItemRemove.bind(null, this.state.department)} />
                        }
                        <Button label="Save" className="p-button-raised" icon="pi pi-check" onClick={this.props.onDataItemSave.bind(null, this.state.department)} />
                    </div>
                </div>
            </Card>
        );
    }
}

DepartmentDetail.propTypes = {
    department: PropTypes.object,
    onDataItemSave: PropTypes.func,
    onDataItemRemove: PropTypes.func
}

DepartmentDetail.defaultProps = {
    department: {}
}

export default DepartmentDetail;