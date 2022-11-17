import React, { Component } from 'react'
import {Button} from 'primereact/button';
import {Card} from 'primereact/card';
import {InputText} from 'primereact/inputtext';
import PropTypes from 'prop-types';
import { Binding } from '../../utils/Util'

class BranchDetail extends Component {
    constructor(props) {
        super(props);
        this.state = {
            branch: this.props.branch
        }
    }

    static getDerivedStateFromProps(props, state) {
        if (props.branch !== state.branch) {
            return {
                branch: props.branch
            };
        }
        return {};
    }

    binding(object, node, e) {
        this.setState({
            branch: Binding.updateByString.bind(null, object, node, e.target.value).call()
        });
    }

    render() {
        return (
            <Card title="Branch Details" className="wc">
                <div className="p-grid">
                    <div className="p-col-12 p-md-6">
                        <h2>ID</h2>
                        <InputText
                            id="branchId"
                            type="number"
                            value={this.state.branch.id || ''}
                            onChange={this.binding.bind(this, this.state.branch, 'id')}
                        />
                    </div>
                    <div className="p-col-12 p-md-6"></div>
                    <div className="p-col-12">
                        <hr></hr>
                    </div>
                    <div className="p-col-12 p-md-6">
                        <h2>Name</h2>
                        <InputText
                            id="branchName"
                            type="text"
                            value={this.state.branch.name || ''}
                            onChange={this.binding.bind(this, this.state.branch, 'name')}
                        />
                    </div>
                    <div className="p-col-12 p-md-6">
                        <h2>City</h2>
                        <InputText
                            id="city"
                            type="text"
                            value={this.state.branch.city || ''}
                            onChange={this.binding.bind(this, this.state.branch, 'city')}
                        />
                    </div>
                    <div className="p-col-12">
                        <h2>Address</h2>
                        <InputText
                            id="branchAddress"
                            type="text"
                            value={this.state.branch.address || ''}
                            onChange={this.binding.bind(this, this.state.branch, 'address')}
                        />
                    </div>
                    <div className="p-col-12">
                        <hr></hr>
                    </div>
                    <div className="p-col-12">
                        <h2>Description</h2>
                        <InputText
                            id="branchDescription"
                            type="text"
                            value={this.state.branch.description || ''}
                            onChange={this.binding.bind(this, this.state.branch, 'description')}
                        />
                    </div>
                    <div className="wc-button-container p-col-12">
                        {!!this.state.branch.id && 
                            <Button label="Delete" className="p-button-raised" icon="pi pi-minus" onClick={this.props.onDataItemRemove.bind(null, this.state.branch)} />
                        }
                        <Button label="Save" className="p-button-raised" icon="pi pi-check" onClick={this.props.onDataItemSave.bind(null, this.state.branch)} />
                    </div>
                </div>
            </Card>
        );
    }
}

BranchDetail.propTypes = {
    branch: PropTypes.object,
    onDataItemSave: PropTypes.func,
    onDataItemRemove: PropTypes.func
}

BranchDetail.defaultProps = {
    branch: {}
}

export default BranchDetail;